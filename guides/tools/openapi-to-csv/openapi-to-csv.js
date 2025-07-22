#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

function parseOpenAPI(filePath) {
    const content = fs.readFileSync(filePath, 'utf8');
    return yaml.load(content);
}

function extractServiceName(fileName) {
    // Remove -api.yaml suffix and convert to readable format
    return fileName.replace(/-api\.yaml$/, '').replace(/-/g, ' ')
        .split(' ')
        .map(word => word.charAt(0).toUpperCase() + word.slice(1))
        .join(' ');
}

function extractDTOStructure(schema) {
    if (!schema || !schema.properties) return '';
    
    return Object.entries(schema.properties)
        .map(([key, value]) => {
            let type = value.type || 'object';
            if (value.items) {
                type = 'array';
            }
            return `${key}:${type}`;
        })
        .join(', ');
}

function convertToCSV(apiSpecs) {
    const headers = [
        '서비스명',
        '마이크로서비스 이름',
        '유저스토리 ID',
        '유저스토리 제목',
        'Controller 이름',
        'API 목적',
        'API Method',
        'API 그룹 Path',
        'API Path',
        'Path 변수',
        'Query 변수',
        'Request DTO 이름',
        'Request DTO 배열 여부',
        'Request DTO 구조',
        'Response DTO 이름',
        'Response DTO 배열 여부',
        'Response DTO 구조'
    ];
    
    const rows = [headers.join('|')];
    
    apiSpecs.forEach(spec => {
        const { fileName, api } = spec;
        const microserviceName = fileName.replace('.yaml', '');
        const serviceName = extractServiceName(fileName);
        
        // Extract base path from servers
        const basePath = api.servers && api.servers[0] ? api.servers[0].url : '';
        
        // Process each path
        Object.entries(api.paths || {}).forEach(([pathUrl, pathItem]) => {
            Object.entries(pathItem).forEach(([method, operation]) => {
                if (['get', 'post', 'put', 'delete', 'patch'].includes(method)) {
                    // Extract path variables
                    const pathVars = [];
                    if (operation.parameters) {
                        operation.parameters
                            .filter(p => p.in === 'path')
                            .forEach(p => pathVars.push(`${p.schema?.type || 'string'} ${p.name}`));
                    }
                    
                    // Extract query variables
                    const queryVars = [];
                    if (operation.parameters) {
                        operation.parameters
                            .filter(p => p.in === 'query')
                            .forEach(p => queryVars.push(`${p.schema?.type || 'string'} ${p.name}`));
                    }
                    
                    // Extract request body info
                    let requestDTOName = '';
                    let requestIsArray = false;
                    let requestStructure = '';
                    
                    if (operation.requestBody && operation.requestBody.content) {
                        const content = operation.requestBody.content['application/json'];
                        if (content && content.schema) {
                            if (content.schema.$ref) {
                                requestDTOName = content.schema.$ref.split('/').pop();
                                const schema = api.components?.schemas?.[requestDTOName];
                                if (schema) {
                                    requestStructure = extractDTOStructure(schema);
                                }
                            } else if (content.schema.type === 'array' && content.schema.items?.$ref) {
                                requestIsArray = true;
                                requestDTOName = content.schema.items.$ref.split('/').pop();
                                const schema = api.components?.schemas?.[requestDTOName];
                                if (schema) {
                                    requestStructure = extractDTOStructure(schema);
                                }
                            }
                        }
                    }
                    
                    // Extract response info
                    let responseDTOName = '';
                    let responseIsArray = false;
                    let responseStructure = '';
                    
                    const successResponse = operation.responses?.['200'] || operation.responses?.['201'];
                    if (successResponse && successResponse.content) {
                        const content = successResponse.content['application/json'];
                        if (content && content.schema) {
                            if (content.schema.$ref) {
                                responseDTOName = content.schema.$ref.split('/').pop();
                                const schema = api.components?.schemas?.[responseDTOName];
                                if (schema) {
                                    responseStructure = extractDTOStructure(schema);
                                }
                            } else if (content.schema.type === 'array' && content.schema.items?.$ref) {
                                responseIsArray = true;
                                responseDTOName = content.schema.items.$ref.split('/').pop();
                                const schema = api.components?.schemas?.[responseDTOName];
                                if (schema) {
                                    responseStructure = extractDTOStructure(schema);
                                }
                            }
                        }
                    }
                    
                    const row = [
                        serviceName,
                        microserviceName,
                        operation['x-user-story'] || '',
                        operation.summary || '',
                        operation['x-controller'] || '',
                        operation.description || operation.summary || '',
                        method.toUpperCase(),
                        basePath,
                        pathUrl,
                        pathVars.join(', '),
                        queryVars.join(', '),
                        requestDTOName,
                        requestIsArray.toString(),
                        requestStructure,
                        responseDTOName,
                        responseIsArray.toString(),
                        responseStructure
                    ];
                    
                    rows.push(row.join('|'));
                }
            });
        });
    });
    
    return rows.join('\n');
}

function main() {
    const args = process.argv.slice(2);
    let inputDir = '.';
    let outputFile = 'API설계서.txt';
    
    // Parse command line arguments
    for (let i = 0; i < args.length; i++) {
        if (args[i] === '-d' && i + 1 < args.length) {
            inputDir = args[i + 1];
            i++;
        } else if (args[i] === '-o' && i + 1 < args.length) {
            outputFile = args[i + 1];
            i++;
        }
    }
    
    // Get all yaml files in the directory
    const yamlFiles = fs.readdirSync(inputDir)
        .filter(file => file.endsWith('.yaml') || file.endsWith('.yml'));
    
    if (yamlFiles.length === 0) {
        console.error('No YAML files found in the directory');
        process.exit(1);
    }
    
    const apiSpecs = [];
    
    yamlFiles.forEach(file => {
        try {
            const filePath = path.join(inputDir, file);
            const api = parseOpenAPI(filePath);
            apiSpecs.push({ fileName: file, api });
            console.log(`Processed: ${file}`);
        } catch (error) {
            console.error(`Error processing ${file}:`, error.message);
        }
    });
    
    if (apiSpecs.length === 0) {
        console.error('No API specifications could be processed');
        process.exit(1);
    }
    
    // Convert to CSV
    const csv = convertToCSV(apiSpecs);
    
    // Write to file
    const outputPath = path.isAbsolute(outputFile) ? outputFile : path.join(process.cwd(), outputFile);
    fs.writeFileSync(outputPath, csv, 'utf8');
    
    console.log(`\nCSV file generated: ${outputPath}`);
    console.log(`Total APIs processed: ${apiSpecs.length}`);
}

if (require.main === module) {
    main();
}

module.exports = { parseOpenAPI, convertToCSV };