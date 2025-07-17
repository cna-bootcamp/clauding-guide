import os
import re
import sys
from pathlib import Path

def print_usage():
    """Print script usage instructions"""
    print("""사용법: 
    python script.py <source_file> <project_path> <project_type>

설명:
    소스 파일로부터 프로젝트 구조를 생성합니다.
    
파라미터:
    source_file  : 소스 파일 경로 (기본값: combined_source.txt)
    project_path : 프로젝트를 생성할 경로 (필수)
    project_type : 's' - 단일 프로젝트, 'm' - 멀티 프로젝트 (필수)

예제:
    python script.py combined_source.txt telecom-cache-pattern s
    python script.py my_source.txt my-project m""")

def process_file_path(base_dir, file_path):
    """파일 경로 처리"""
    # 'File:' 패턴 제거
    path = re.sub(r'^File:\s*', '', file_path)
    
    # base 디렉토리가 경로에 포함되어 있으면 제거
    base_pattern = f"^{re.escape(base_dir)}(/|\\\\)?"
    path = re.sub(base_pattern, '', path, flags=re.IGNORECASE)
    
    # 경로 구분자 정규화
    path = path.replace('\\', '/')
    
    # 연속된 '/'와 공백 제거
    path = re.sub(r'/+', '/', path)
    path = path.strip()
    
    return path

def parse_java_file(content):
    """Parse the combined Java source file into separate files with project structure"""
    files = {}
    current_file = None
    current_content = []
    has_package = False  # package 문 존재 여부 확인
    
    lines = content.split('\n')
    for line in lines:
        # File marker starts with //
        if line.startswith('// '):
            # Save previous file if exists
            if current_file and current_content:
                files[current_file] = '\n'.join(current_content)
                current_content = []
                has_package = False  # 새 파일 시작시 초기화
            
            current_file = line[3:].strip()  # Remove '// ' prefix
        else:
            # Skip empty lines at the beginning
            if not current_file and not line.strip():
                continue
                
            # 현재 라인이 package 문인지 확인
            if line.strip().startswith('package '):
                has_package = True
                
            # package 문이 없고, 첫 번째 의미 있는 라인이 import나 class/interface/enum 선언이면
            # 해당 파일의 경로에서 package 이름을 추출하여 추가
            if not has_package and line.strip() and \
               (line.strip().startswith('import ') or \
                any(keyword in line for keyword in ['class ', 'interface ', 'enum '])):
                # 파일 경로에서 package 이름 추출
                if 'src/main/java' in current_file:
                    path_parts = current_file.split('/')
                    java_idx = path_parts.index('java')
                    if len(path_parts) > java_idx + 1:
                        package_parts = path_parts[java_idx + 1:-1]  # 마지막은 파일 이름이므로 제외
                        if package_parts:
                            package_name = '.'.join(package_parts)
                            current_content.append(f"package {package_name};")
                            current_content.append("")  # 빈 줄 추가
                            has_package = True  # package 추가 완료
            
            current_content.append(line)
    
    # Save the last file
    if current_file and current_content:
        files[current_file] = '\n'.join(current_content)
    
    return files
    

def process_single_project(file_path, content):
    """Process file path for single project structure"""
    # 루트 레벨 파일 처리
    if file_path in ['build.gradle', 'settings.gradle']:
        return file_path
        
    # Java 파일 처리
    if file_path.endswith('.java'):
        # 원본 경로에서 서브프로젝트 부분을 제거하고 src/main/java로 시작하도록 수정
        path_parts = file_path.split('/')
        # 서브프로젝트 폴더와 src/main/java를 제외한 나머지 경로 사용
        if 'src/main/java' in file_path:
            java_index = path_parts.index('java')
            relative_path = '/'.join(path_parts[java_index + 1:])
            return f"src/main/java/{relative_path}"
        else:
            # src/main/java가 없는 경우, 패키지 구조만 사용
            package_match = re.search(r'package\s+([\w.]+);', content)
            if package_match:
                package = package_match.group(1)
                package_path = package.replace('.', '/')
                file_name = os.path.basename(file_path)
                return f"src/main/java/{package_path}/{file_name}"
    
    # 리소스 파일 처리
    if 'src/main/resources' in file_path:
        path_parts = file_path.split('/')
        resources_index = path_parts.index('resources')
        relative_path = '/'.join(path_parts[resources_index:])
        return f"src/main/{relative_path}"
        
    return None

def process_multi_project(file_path, content):
    """Process file path for multi project structure"""
    # 루트 프로젝트 파일 처리
    if file_path in ['build.gradle', 'settings.gradle']:
        return file_path
    
    # 원본 경로 그대로 사용 (이미 올바른 구조를 가지고 있음)
    return file_path

def create_project_structure(base_path, project_type, files):
    """Create project structure and write files"""
    created_files = []
    for file_path, content in files.items():
        try:
            # base 디렉토리 없는 경로로 변환
            normalized_path = process_file_path(base_path, file_path)
            print(f"Processing: {file_path} -> {normalized_path}")
            
            # 프로젝트 타입에 따라 다른 처리 로직 적용
            if project_type == 's':
                full_path = process_single_project(normalized_path, content)
            else:  # 'm'
                full_path = process_multi_project(normalized_path, content)
            
            if full_path:
                # 최종 경로 생성
                absolute_path = os.path.join(base_path, full_path)
                os.makedirs(os.path.dirname(absolute_path), exist_ok=True)
                
                # 파일 생성
                with open(absolute_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                created_files.append(absolute_path)
                print(f"Created: {absolute_path}")
        
        except Exception as e:
            print(f"Error processing file {file_path}: {str(e)}")
            continue
    
    return created_files

def main(source_file, project_path, project_type):
    """Main function to convert source to project"""
    # Check if source file exists
    if not os.path.exists(source_file):
        print(f"Error: Source file '{source_file}' not found.")
        return
    
    try:
        # Validate project type
        if project_type not in ['s', 'm']:
            raise ValueError("프로젝트 타입은 's'(단일) 또는 'm'(멀티)이어야 합니다.")
        
        # Read source file
        with open(source_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Parse files
        files = parse_java_file(content)
        
        project_type_name = "단일" if project_type == 's' else "멀티"
        print(f"\n{project_type_name} 프로젝트를 생성합니다: {project_path}")
        
        # Create project structure
        created_files = create_project_structure(project_path, project_type, files)
        
        print(f"\n프로젝트가 성공적으로 생성되었습니다: {project_path}")
        print(f"프로젝트 타입: {project_type_name}")
        print("\n생성된 파일:")
        
        # 생성된 파일을 프로젝트 기준으로 그룹화하여 출력
        if project_type == 'm':
            projects = {}
            for file in created_files:
                rel_path = os.path.relpath(file, project_path)
                project = rel_path.split(os.sep)[0]
                if project not in projects:
                    projects[project] = []
                projects[project].append(rel_path)
            
            # 루트 프로젝트 파일 출력
            root_files = [f for f in projects.get('', []) if '/' not in f]
            if root_files:
                print("\n루트 프로젝트:")
                for file in sorted(root_files):
                    print(f"  - {file}")
            
            # 서브프로젝트 파일 출력
            for project in sorted(projects.keys()):
                if project and project != '':
                    print(f"\n서브프로젝트 - {project}:")
                    for file in sorted(projects[project]):
                        print(f"  - {file}")
        else:
            # 단일 프로젝트는 단순 리스트로 출력
            for file in sorted(created_files):
                rel_path = os.path.relpath(file, project_path)
                print(f"  - {rel_path}")
            
    except ValueError as e:
        print(f"Error: {str(e)}")
    except Exception as e:
        print(f"Error occurred: {str(e)}")

if __name__ == "__main__":
    # Set default source file
    source_file = "combined_source.txt"
    
    # Check argument count
    if len(sys.argv) < 3 or len(sys.argv) > 4:
        print_usage()
        sys.exit(1)
    
    # Parse arguments
    if len(sys.argv) == 3:
        project_path = sys.argv[1]
        project_type = sys.argv[2]
    else:  # len(sys.argv) == 4
        source_file = sys.argv[1]
        project_path = sys.argv[2]
        project_type = sys.argv[3]
    
    # Validate project type
    if project_type not in ['s', 'm']:
        print("Error: 프로젝트 타입은 's'(단일) 또는 'm'(멀티)이어야 합니다.")
        print_usage()
        sys.exit(1)
    
    main(source_file, project_path, project_type)