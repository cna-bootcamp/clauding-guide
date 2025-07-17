#!/usr/bin/env python3

import os
import sys

def print_usage():
    """Print script usage instructions"""
    print("""사용법: 
    python generate-project.py <source_file> <project_name>

설명:
    소스 파일로부터 React 프로젝트 구조를 생성합니다.
    
파라미터:
    source_file  : 소스 파일 경로
    project_name : 생성할 프로젝트 이름

예제:
    python generate-project.py source.txt my-subscription-app""")

def parse_source_file(content):
    """Parse the source file content and extract files with their paths and content
    
    Args:
        content (str): Source file content
        
    Returns:
        dict: Dictionary with file paths as keys and file contents as values
    """
    lines = content.split('\n')
    files = {}
    current_file = None
    current_content = []

    for line in lines:
        # Check if this line indicates a new file path
        if line.startswith('//* '):
            # Save the previous file if exists
            if current_file and current_content:
                files[current_file] = '\n'.join(current_content)
                current_content = []
            
            # Extract the file path
            current_file = line[4:].strip()
        else:
            # Add content to the current file
            current_content.append(line)
    
    # Save the last file
    if current_file and current_content:
        files[current_file] = '\n'.join(current_content)
    
    return files

def create_directories(project_path, file_path):
    """Create the directory structure for a file path
    
    Args:
        project_path (str): Base project path
        file_path (str): File path relative to the project
    """
    directory_path = os.path.dirname(os.path.join(project_path, file_path))
    
    if not os.path.exists(directory_path):
        os.makedirs(directory_path, exist_ok=True)
        print(f"Created directory: {directory_path}")

def create_file(project_path, file_path, content):
    """Create a file with the given content
    
    Args:
        project_path (str): Base project path
        file_path (str): File path relative to the project
        content (str): File content
    """
    full_path = os.path.join(project_path, file_path)
    create_directories(project_path, file_path)
    
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Created file: {full_path}")

def generate_project(source_file, project_name):
    """Main function to generate project from source
    
    Args:
        source_file (str): Path to source file
        project_name (str): Project name to create
    """
    try:
        # Create project directory if it doesn't exist
        if not os.path.exists(project_name):
            os.makedirs(project_name)
            print(f"Created project directory: {project_name}")
        
        # Read the source file
        with open(source_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse the source file to extract files
        files = parse_source_file(content)
        
        # Generate file structure
        file_count = 0
        for file_path, file_content in files.items():
            create_file(project_name, file_path, file_content)
            file_count += 1
        
        print(f"\nProject generation completed successfully!")
        print(f"Created {file_count} files in {project_name}")
        
        print(f"\nTo use the generated project:")
        print(f"1. cd {project_name}")
        print(f"2. npm install (to install dependencies)")
        print(f"3. npm start (to start the development server)")
        
    except Exception as e:
        print(f"Error generating project: {str(e)}")
        sys.exit(1)

def main():
    """Main execution function"""
    args = sys.argv[1:]
    
    # Check for correct number of arguments
    if len(args) != 2:
        print('Error: Incorrect number of arguments')
        print_usage()
        sys.exit(1)
    
    source_file, project_name = args
    
    # Check if source file exists
    if not os.path.exists(source_file):
        print(f"Error: Source file '{source_file}' not found")
        sys.exit(1)
    
    print(f"Generating React project structure from {source_file} to {project_name}...")
    generate_project(source_file, project_name)

if __name__ == "__main__":
    main()

