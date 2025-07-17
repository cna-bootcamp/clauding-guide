#!/usr/bin/env python3

import os
import sys
import stat

def print_usage():
    """Print script usage instructions"""
    print("""사용법: 
    python genpy.py <source_file> <project_name>

설명:
    소스 파일로부터 Python 프로젝트 구조를 생성합니다.
    
파라미터:
    source_file  : 소스 파일 경로
    project_name : 생성할 프로젝트 이름

예제:
    python genpy.py aisrc.txt ai-review-analyzer""")

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
    in_code_block = False

    for line in lines:
        # Check if this line starts a code block
        if line.strip().startswith('```') or line.strip().startswith('# '):
            if line.strip().startswith('```'):
                in_code_block = not in_code_block
                continue
            
        # Check if this line indicates a new file path (starts with # and contains file extension)
        if line.startswith('# ') and ('.' in line or line.endswith('/')):
            # Save the previous file if exists
            if current_file and current_content:
                files[current_file] = '\n'.join(current_content)
                current_content = []
            
            # Extract the file path
            current_file = line[2:].strip()
            
            # Skip if it's just a comment without file extension
            if not ('.' in current_file or current_file.endswith('/')):
                current_file = None
                continue
                
        elif current_file and in_code_block:
            # Add content to the current file only if we're inside a code block
            current_content.append(line)
        elif current_file and not in_code_block and line.strip() and not line.startswith('#'):
            # Add content to the current file if it's not a comment and not empty
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
    
    if directory_path and not os.path.exists(directory_path):
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
    
    # Clean up content - remove any remaining code block markers
    content = content.strip()
    if content.startswith('```'):
        lines = content.split('\n')
        # Remove first line if it's a code block marker
        if lines[0].strip().startswith('```'):
            lines = lines[1:]
        # Remove last line if it's a code block marker
        if lines and lines[-1].strip() == '```':
            lines = lines[:-1]
        content = '\n'.join(lines)
    
    with open(full_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    # Make Python files executable
    if file_path.endswith('.py'):
        st = os.stat(full_path)
        os.chmod(full_path, st.st_mode | stat.S_IEXEC)
    
    print(f"Created file: {full_path}")

def create_init_files(project_path, files):
    """Create __init__.py files for Python packages
    
    Args:
        project_path (str): Base project path
        files (dict): Dictionary of files to check for package directories
    """
    python_dirs = set()
    
    # Find all directories that contain Python files
    for file_path in files.keys():
        if file_path.endswith('.py'):
            dir_path = os.path.dirname(file_path)
            while dir_path:
                python_dirs.add(dir_path)
                dir_path = os.path.dirname(dir_path)
    
    # Create __init__.py files for each Python package directory
    for dir_path in python_dirs:
        if dir_path:  # Skip root directory
            init_file = os.path.join(dir_path, '__init__.py')
            if init_file not in files:
                full_init_path = os.path.join(project_path, init_file)
                create_directories(project_path, init_file)
                
                with open(full_init_path, 'w', encoding='utf-8') as f:
                    f.write('# Package initialization file\n')
                print(f"Created __init__.py: {full_init_path}")

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
        
        if not files:
            print("No files found in the source. Make sure your source file has proper file markers (# filename)")
            return
        
        # Create __init__.py files for Python packages
        create_init_files(project_name, files)
        
        # Generate file structure
        file_count = 0
        for file_path, file_content in files.items():
            if file_content.strip():  # Only create files with content
                create_file(project_name, file_path, file_content)
                file_count += 1
        
        # Create .env file from .env.example if it exists
        env_example_path = os.path.join(project_name, '.env.example')
        env_path = os.path.join(project_name, '.env')
        if os.path.exists(env_example_path) and not os.path.exists(env_path):
            with open(env_example_path, 'r', encoding='utf-8') as f:
                env_content = f.read()
            with open(env_path, 'w', encoding='utf-8') as f:
                f.write(env_content)
            print(f"Created .env file from .env.example")
        
        print(f"\nProject generation completed successfully!")
        print(f"Created {file_count} files in {project_name}")
        
        print(f"\nTo use the generated project:")
        print(f"1. cd {project_name}")
        print(f"2. python -m venv venv(PC에서는 python3 사용)")
        print(f"3. source venv/bin/activate  # Windows: venv\\Scripts\\activate")
        print(f"4. pip install -r requirements.txt")
        print(f"5. Edit .env file to configure your API keys and database settings")
        print(f"6. docker-compose up -d  # Start PostgreSQL, Redis, ChromaDB")
        print(f"7. python main.py  # Start the API server")
        
        # Check for specific files and provide additional instructions
        if any('batch/' in f for f in files.keys()):
            print(f"\nFor batch processing:")
            print(f"   python -m batch.daily_collector  # Daily review collection")
            print(f"   python -m batch.vector_builder   # Vector DB building")
        
        if 'docker-compose.yml' in files:
            print(f"\nAPI Documentation:")
            print(f"   Swagger UI: http://localhost:8000/docs")
            print(f"   ReDoc: http://localhost:8000/redoc")
        
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
    
    print(f"Generating Python project structure from {source_file} to {project_name}...")
    generate_project(source_file, project_name)

if __name__ == "__main__":
    main()
