#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');
const { program } = require('commander');

// 서비스명 한글 매핑
const serviceNameMap = {
  'user-service-api': '사용자 서비스',
  'trip-service-api': '여행 서비스',
  'ai-service-api': 'AI 서비스',
  'location-service-api': '장소 서비스'
};

// CSV 헤더
const csvHeaders = [
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

// OpenAPI 파일 읽기 및 파싱
function readOpenAPIFile(filePath) {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return yaml.load(content);
  } catch (error) {
    console.error(`Error reading file ${filePath}:`, error.message);
    return null;
  }
}

// DTO 구조를 문자열로 변환
function dtoStructureToString(schema, schemas) {
  if (!schema) return '';
  
  const properties = [];
  
  if (schema.$ref) {
    const refName = schema.$ref.split('/').pop();
    const refSchema = schemas[refName];
    if (refSchema && refSchema.properties) {
      for (const [key, value] of Object.entries(refSchema.properties)) {
        const type = value.type || 'object';
        properties.push(`${key}:${type}`);
      }
    }
  } else if (schema.properties) {
    for (const [key, value] of Object.entries(schema.properties)) {
      const type = value.type || 'object';
      properties.push(`${key}:${type}`);
    }
  }
  
  return properties.join(', ');
}

// API 정보를 CSV 행으로 변환
function apiToCSVRow(api, serviceName, serverUrl, schemas) {
  const row = [];
  
  // 서비스명
  const baseServiceName = serviceName.replace('-api.yaml', '');
  row.push(serviceNameMap[baseServiceName] || baseServiceName);
  
  // 마이크로서비스 이름
  row.push(serviceName.replace('.yaml', ''));
  
  // 유저스토리 ID
  row.push(api['x-user-story'] || '');
  
  // 유저스토리 제목 (summary)
  row.push(api.summary || '');
  
  // Controller 이름
  row.push(api['x-controller'] || '');
  
  // API 목적
  row.push(api.description || api.summary || '');
  
  // API Method
  row.push(api.method.toUpperCase());
  
  // API 그룹 Path (base path 추출)
  let basePath = '';
  if (serverUrl) {
    try {
      const url = new URL(serverUrl);
      basePath = url.pathname || '/';
    } catch (e) {
      basePath = serverUrl;
    }
  }
  row.push(basePath);
  
  // API Path
  row.push(api.path);
  
  // Path 변수
  const pathParams = [];
  if (api.parameters) {
    api.parameters
      .filter(p => p.in === 'path')
      .forEach(p => pathParams.push(`${p.schema?.type || 'string'} ${p.name}`));
  }
  row.push(pathParams.join(', '));
  
  // Query 변수
  const queryParams = [];
  if (api.parameters) {
    api.parameters
      .filter(p => p.in === 'query')
      .forEach(p => queryParams.push(`${p.schema?.type || 'string'} ${p.name}`));
  }
  row.push(queryParams.join(', '));
  
  // Request DTO 정보
  let requestDTOName = '';
  let requestIsArray = false;
  let requestStructure = '';
  
  if (api.requestBody && api.requestBody.content) {
    const content = api.requestBody.content['application/json'];
    if (content && content.schema) {
      if (content.schema.type === 'array') {
        requestIsArray = true;
        if (content.schema.items && content.schema.items.$ref) {
          requestDTOName = content.schema.items.$ref.split('/').pop();
        }
      } else if (content.schema.$ref) {
        requestDTOName = content.schema.$ref.split('/').pop();
      }
      requestStructure = dtoStructureToString(
        requestIsArray ? content.schema.items : content.schema,
        schemas
      );
    }
  }
  
  row.push(requestDTOName);
  row.push(requestIsArray ? 'true' : 'false');
  row.push(requestStructure);
  
  // Response DTO 정보
  let responseDTOName = '';
  let responseIsArray = false;
  let responseStructure = '';
  
  if (api.responses && api.responses['200'] && api.responses['200'].content) {
    const content = api.responses['200'].content['application/json'];
    if (content && content.schema) {
      if (content.schema.type === 'array') {
        responseIsArray = true;
        if (content.schema.items && content.schema.items.$ref) {
          responseDTOName = content.schema.items.$ref.split('/').pop();
        }
      } else if (content.schema.$ref) {
        responseDTOName = content.schema.$ref.split('/').pop();
      }
      responseStructure = dtoStructureToString(
        responseIsArray ? content.schema.items : content.schema,
        schemas
      );
    }
  }
  
  row.push(responseDTOName);
  row.push(responseIsArray ? 'true' : 'false');
  row.push(responseStructure);
  
  return row;
}

// OpenAPI 파일을 CSV로 변환
function convertOpenAPIToCSV(openapi, fileName) {
  const rows = [];
  // Production 서버 URL을 우선적으로 사용 (base path 추출용)
  let serverUrl = '';
  if (openapi.servers && openapi.servers.length > 0) {
    // Production 서버 찾기 (api.tripgen.com 포함)
    const prodServer = openapi.servers.find(s => s.url.includes('api.tripgen.com'));
    serverUrl = prodServer ? prodServer.url : openapi.servers[0].url;
  }
  const schemas = openapi.components?.schemas || {};
  
  // 모든 경로와 메서드 순회
  for (const [path, pathItem] of Object.entries(openapi.paths || {})) {
    for (const [method, operation] of Object.entries(pathItem)) {
      if (['get', 'post', 'put', 'delete', 'patch'].includes(method)) {
        const api = {
          ...operation,
          method,
          path
        };
        rows.push(apiToCSVRow(api, fileName, serverUrl, schemas));
      }
    }
  }
  
  return rows;
}

// CSV 파일 작성 (서비스별 분리 + 전치 형태)
function writeCSVFile(rows, outputPath) {
  // 서비스별로 그룹화
  const serviceGroups = {};
  
  rows.forEach(row => {
    const serviceName = row[0]; // 서비스명은 첫 번째 컬럼
    if (!serviceGroups[serviceName]) {
      serviceGroups[serviceName] = [];
    }
    serviceGroups[serviceName].push(row);
  });
  
  // 마크다운 내용 생성
  let markdownContent = `# API 설계서

## API 목록 (서비스별 분리, 전치된 CSV 형식)

### 읽는 방법
- 각 서비스별로 분리되어 있습니다
- 첫 번째 열: 필드명 (서비스명, 마이크로서비스 이름, 유저스토리 ID 등)
- 두 번째 열부터: 각 API의 정보

`;
  
  // 서비스별로 전치된 테이블 생성
  Object.entries(serviceGroups).forEach(([serviceName, serviceRows]) => {
    markdownContent += `### ${serviceName}\n\n`;
    
    // 서비스별 데이터 전치
    const serviceData = [csvHeaders, ...serviceRows];
    const transposedData = [];
    
    for (let i = 0; i < csvHeaders.length; i++) {
      const transposedRow = serviceData.map(row => row[i] || '');
      transposedData.push(transposedRow);
    }
    
    // CSV 형식으로 변환
    const content = transposedData.map(row => row.join('|')).join('\n');
    markdownContent += content + '\n\n';
  });
  
  markdownContent += `## 사용 방법
- 이 파일은 파이프(|)로 구분된 CSV 형식입니다
- 각 서비스별로 테이블이 분리되어 있습니다
- 각 행은 하나의 속성을 나타내며, 각 열은 하나의 API를 나타냅니다
- Excel에서 열 때 구분자를 파이프(|)로 설정하여 열어주세요
- 또는 CSV 뷰어에서 구분자를 파이프(|)로 설정하여 보실 수 있습니다

## 생성 정보
- 생성일시: ${new Date().toISOString()}
- 생성 도구: openapi-to-csv
- 총 API 수: ${rows.length}개
- 형식: 서비스별 분리 + 전치된 CSV (행과 열이 바뀐 형태)
`;
  
  fs.writeFileSync(outputPath, markdownContent, 'utf8');
  console.log(`CSV 파일이 생성되었습니다: ${outputPath}`);
}

// 메인 함수
function main() {
  program
    .version('1.0.0')
    .description('OpenAPI 3.0 YAML 파일을 CSV로 변환합니다')
    .option('-d, --directory <dir>', '입력 디렉토리', '.')
    .option('-o, --output <file>', '출력 파일명', 'API설계서.md')
    .parse(process.argv);

  const options = program.opts();
  const inputDir = path.resolve(options.directory);
  const outputFile = path.resolve(options.output);

  // YAML 파일 찾기
  const yamlFiles = fs.readdirSync(inputDir)
    .filter(file => file.endsWith('.yaml') || file.endsWith('.yml'))
    .map(file => path.join(inputDir, file));

  if (yamlFiles.length === 0) {
    console.error(`${inputDir} 디렉토리에서 YAML 파일을 찾을 수 없습니다.`);
    process.exit(1);
  }

  console.log(`${yamlFiles.length}개의 YAML 파일을 찾았습니다.`);

  // 모든 API 정보 수집
  const allRows = [];
  
  for (const yamlFile of yamlFiles) {
    console.log(`처리중: ${path.basename(yamlFile)}`);
    const openapi = readOpenAPIFile(yamlFile);
    
    if (openapi) {
      const rows = convertOpenAPIToCSV(openapi, path.basename(yamlFile));
      allRows.push(...rows);
    }
  }

  // CSV 파일 작성
  if (allRows.length > 0) {
    writeCSVFile(allRows, outputFile);
    console.log(`총 ${allRows.length}개의 API가 변환되었습니다.`);
  } else {
    console.error('변환할 API가 없습니다.');
  }
}

// 실행
if (require.main === module) {
  main();
}

module.exports = { convertOpenAPIToCSV, writeCSVFile };