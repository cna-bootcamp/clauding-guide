import os
import yaml

def find_yaml_files(root_dir):
    # 하위 디렉토리와 yaml 파일 정보를 저장할 딕셔너리
    yaml_files = {}
    
    # root_dir을 재귀적으로 탐색
    for dirpath, dirnames, filenames in os.walk(root_dir):
        # 최상위 디렉토리는 건너뛰기
        if dirpath == root_dir:
            continue
            
        # yaml 파일만 필터링
        yaml_filenames = [f for f in filenames if f.endswith(('.yaml', '.yml'))]
        if yaml_filenames:
            # 상대 경로를 키로 사용
            rel_dir = os.path.relpath(dirpath, root_dir)
            yaml_files[rel_dir] = sorted(yaml_filenames)
    
    return yaml_files

def merge_yaml_files(root_dir, output_file):
    # YAML 파일 찾기
    yaml_files = find_yaml_files(root_dir)
    
    # 찾은 하위 디렉토리 출력
    print("\nFound directories with YAML files:")
    for dir_name in yaml_files.keys():
        print(f"- {dir_name}")

    # 결과 파일 작성
    with open(output_file, 'w', encoding='utf-8') as outfile:
        dirs = sorted(yaml_files.keys())
        
        # 각 디렉토리 처리
        for dir_idx, dir_name in enumerate(dirs):
            print(f"\nProcessing directory: {dir_name}")
            
            # 디렉토리 내 yaml 파일 처리
            for file_idx, filename in enumerate(yaml_files[dir_name]):
                file_path = os.path.join(root_dir, dir_name, filename)
                print(f"Reading file: {filename}")
                
                with open(file_path, 'r', encoding='utf-8') as infile:
                    try:
                        # YAML 문서 로드
                        docs = list(yaml.safe_load_all(infile))
                        
                        # 각 문서를 결과 파일에 쓰기
                        for doc_idx, doc in enumerate(docs):
                            if doc:  # None이 아닌 경우만 추가
                                yaml.dump(doc, outfile, default_flow_style=False, allow_unicode=True)
                                
                                # 구분자 추가 조건:
                                # 1. 현재 문서가 현재 파일의 마지막 문서가 아니거나
                                # 2. 현재 파일이 현재 디렉토리의 마지막 파일이 아니거나
                                # 3. 현재 디렉토리가 마지막 디렉토리가 아닐 때
                                if (doc_idx < len(docs) - 1 or 
                                    file_idx < len(yaml_files[dir_name]) - 1 or 
                                    dir_idx < len(dirs) - 1):
                                    outfile.write('\n---\n')
                                    
                    except yaml.YAMLError as e:
                        print(f"Error reading {file_path}: {e}")

    print(f"\nMerged manifest file created at: {os.path.abspath(output_file)}")

if __name__ == "__main__":
    manifest_dir = input("Manifest파일들이 있는 최상위 디렉토리를 입력: ")
    output_file = input("결과 파일명 입력 (기본값: manifest.yaml): ").strip()
    
    # 기본값 설정
    if not output_file:
        output_file = "manifest.yaml"
        
    merge_yaml_files(manifest_dir, output_file)