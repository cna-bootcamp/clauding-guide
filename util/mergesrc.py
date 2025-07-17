import os

def merge_files(src_directories, output_file, extensions=['.java', '.yml', '.gradle']):
    with open(output_file, 'w', encoding='utf-8') as outfile:
        for src_directory in src_directories:
            for root, dirs, files in os.walk(src_directory):
                for file in files:
                    if any(file.endswith(ext) for ext in extensions):
                        file_path = os.path.join(root, file)
                        try:
                            with open(file_path, 'r', encoding='utf-8') as infile:
                                content = infile.read()
                                if content:
                                    outfile.write(f"// File: {file_path}\n")
                                    outfile.write(content)
                                    outfile.write("\n\n")
                                    print(f"Added {file_path}")
                                else:
                                    print(f"Skipped empty file: {file_path}")
                        except Exception as e:
                            print(f"Error reading {file_path}: {e}")

        # 현재 디렉토리의 settings.gradle과 build.gradle 파일 추가
        current_dir = os.path.abspath(os.path.dirname(__file__))
        for file_name in ['settings.gradle', 'build.gradle']:
            file_path = os.path.join(current_dir, file_name)
            if os.path.isfile(file_path):
                try:
                    with open(file_path, 'r', encoding='utf-8') as infile:
                        content = infile.read()
                        if content:
                            outfile.write(f"// File: {file_path}\n")
                            outfile.write(content)
                            outfile.write("\n\n")
                            print(f"Added {file_path}")
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")


if __name__ == "__main__":
    default_directories = ""
    input_directories = input(f"# 소스 디렉토리명 (기본값: {default_directories}): ")

    if input_directories.strip() == "":
        src_directories = default_directories.split()
    else:
        src_directories = input_directories.split()

    output_file = 'MergedSource.java'
    merge_files(src_directories, output_file)
    print(f"All files have been merged into {output_file}")
