#!/usr/bin/env python3
import os
import sys
from datetime import datetime

def read_file_content(file_path):
    """
    Read and return the content of a file with proper error handling.
    
    Args:
        file_path (str): Path to the file to read
    
    Returns:
        str: Content of the file or None if file cannot be read
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        print(f"Error reading {file_path}: {str(e)}")
        return None

def is_text_file(filename):
    """
    Check if a file is a text file based on its extension.
    
    Args:
        filename (str): Name of the file to check
        
    Returns:
        bool: True if the file is a text file, False otherwise
    """
    # List of extensions to exclude (images, icons, and other binary files)
    excluded_extensions = {
        '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.svg',
        '.ttf', '.woff', '.woff2', '.eot', '.otf',
        '.mp4', '.webm', '.ogg', '.mp3', '.wav',
        '.pdf', '.zip', '.tar', '.gz'
    }
    
    # List of extensions to include (common text files in React projects)
    included_extensions = {
        '.js', '.jsx', '.ts', '.tsx', '.css', '.scss', '.less',
        '.html', '.json', '.md', '.txt', '.env',
        '.gitignore', '.eslintrc', '.prettierrc', '.babelrc'
    }
    
    _, ext = os.path.splitext(filename.lower())
    
    # If no extension, check if it's a config file we want to include
    if not ext and filename in {'package.json', '.env', '.gitignore', '.npmrc'}:
        return True
        
    return ext in included_extensions and ext not in excluded_extensions

def process_directory(dir_path, output_lines):
    """
    Recursively process a directory and add all file contents to output_lines.
    
    Args:
        dir_path (str): Path to the directory to process
        output_lines (list): List to store file contents
    """
    try:
        for root, _, files in os.walk(dir_path):
            for file in files:
                # Skip hidden files and non-text files
                if file.startswith('.') or not is_text_file(file):
                    continue
                    
                file_path = os.path.join(root, file)
                relative_path = os.path.relpath(file_path, project_path)
                
                content = read_file_content(file_path)
                if content is not None:
                    output_lines.extend([
                        f"\n// File: {relative_path}",
                        content
                    ])
    except Exception as e:
        print(f"Error processing directory {dir_path}: {str(e)}")

def merge_react_files(project_path):
    """
    Merge files from a React project into a single file.
    
    Args:
        project_path (str): Path to the React project root directory
    
    Returns:
        str: Path to the generated output file
    """
    if not os.path.isdir(project_path):
        print(f"Error: {project_path} is not a valid directory")
        return None
        
    output_lines = [
        f"// React Project: {os.path.basename(project_path)}",
        f"// Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
    ]
    
    # Process package.json
    package_json = os.path.join(project_path, 'package.json')
    if os.path.exists(package_json):
        content = read_file_content(package_json)
        if content:
            output_lines.extend([
                "\n// File: package.json",
                content
            ])
    
    # Process .env
    env_file = os.path.join(project_path, '.env')
    if os.path.exists(env_file):
        content = read_file_content(env_file)
        if content:
            output_lines.extend([
                "\n// File: .env",
                content
            ])
    
    # Process public directory
    public_dir = os.path.join(project_path, 'public')
    if os.path.exists(public_dir):
        process_directory(public_dir, output_lines)
    
    # Process src directory
    src_dir = os.path.join(project_path, 'src')
    if os.path.exists(src_dir):
        process_directory(src_dir, output_lines)
    
    # Write output file
    output_file = f"MergeFront.txt"
    try:
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write('\n'.join(output_lines))
        print(f"Successfully created {output_file}")
        return output_file
    except Exception as e:
        print(f"Error writing output file: {str(e)}")
        return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python merge_react_files.py <react_project_path>")
        sys.exit(1)
    
    project_path = os.path.abspath(sys.argv[1])
    merge_react_files(project_path)

