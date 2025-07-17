#!/usr/bin/env python3
"""
소스 루트 디렉토리의 모든 Python 파일(.py)을 하나로 merge하는 스크립트
"""

import os
import sys
from pathlib import Path
from datetime import datetime

def merge_source_files(
    source_root: str,
    output_file: str = None,
    encoding: str = "utf-8"
):
    """
    소스 루트 디렉토리 하위 모든 Python 파일들을 하나로 merge
    
    Args:
        source_root: 소스 루트 디렉토리 경로
        output_file: 출력 파일명 (None이면 자동 생성)
        encoding: 파일 인코딩 (기본값: utf-8)
    """
    
    # 지원하는 파일 확장자 (Python 파일만)
    SUPPORTED_EXTENSIONS = {
        '.py'
    }
    
    # 제외할 파일/폴더 패턴
    EXCLUDE_PATTERNS = {
        '__pycache__', '.git', '.pytest_cache', 'node_modules', 
        '.venv', 'venv', '.env', 'dist', 'build', '.DS_Store',
        '*.pyc', '*.pyo', '*.pyd', '.coverage', '.idea', '.vscode',
        'target', 'bin', 'obj', '.next', '.nuxt', 'coverage',
        '*.log', '*.tmp', '*.cache', '.gradle', '.maven'
    }
    
    source_path = Path(source_root)
    
    if not source_path.exists():
        print(f"❌ 소스 루트 디렉토리가 존재하지 않습니다: {source_path}")
        return False
    
    if not source_path.is_dir():
        print(f"❌ 소스 루트 디렉토리가 디렉토리가 아닙니다: {source_path}")
        return False
    
    # 출력 파일명 자동 생성
    if output_file is None:
        source_name = source_path.name
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f"{source_name}_merged_{timestamp}.txt"
    
    merged_content = []
    file_count = 0
    total_lines = 0
    
    # 헤더 정보 추가
    header = f"""
{'='*80}
Python 소스 파일 통합 문서
{'='*80}
소스명: {source_path.name}
생성일시: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
소스 경로: {source_path.absolute()}
{'='*80}

"""
    merged_content.append(header)
    
    # 파일 트리 구조 생성
    def create_file_tree(path: Path, prefix: str = "", max_depth: int = 10, current_depth: int = 0):
        """파일 트리 구조 생성"""
        if current_depth > max_depth:
            return []
        
        tree_lines = []
        try:
            items = sorted([item for item in path.iterdir() if not should_exclude(item)])
        except PermissionError:
            return [f"{prefix}❌ 접근 권한 없음"]
        
        for i, item in enumerate(items):
            is_last = i == len(items) - 1
            current_prefix = "└── " if is_last else "├── "
            tree_lines.append(f"{prefix}{current_prefix}{item.name}")
            
            if item.is_dir() and current_depth < max_depth:
                next_prefix = prefix + ("    " if is_last else "│   ")
                tree_lines.extend(create_file_tree(item, next_prefix, max_depth, current_depth + 1))
        
        return tree_lines
    
    def should_exclude(path: Path) -> bool:
        """파일/폴더 제외 여부 판단"""
        name = path.name
        
        # 숨김 파일 제외 (단, .gitignore, .env 등은 포함)
        if name.startswith('.') and name not in {'.gitignore', '.env', '.dockerignore', '.editorconfig'}:
            return True
        
        # 제외 패턴 확인
        for pattern in EXCLUDE_PATTERNS:
            if pattern.startswith('*'):
                if name.endswith(pattern[1:]):
                    return True
            else:
                if name == pattern:
                    return True
        
        return False
    
    def get_file_info(file_path: Path) -> dict:
        """파일 정보 수집"""
        try:
            stat = file_path.stat()
            return {
                'size': stat.st_size,
                'modified': datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S'),
                'extension': file_path.suffix
            }
        except Exception:
            return {'size': 0, 'modified': 'Unknown', 'extension': ''}
    
    def format_file_size(size_bytes: int) -> str:
        """파일 크기를 읽기 쉬운 형태로 변환"""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024**2:
            return f"{size_bytes/1024:.1f} KB"
        elif size_bytes < 1024**3:
            return f"{size_bytes/(1024**2):.1f} MB"
        else:
            return f"{size_bytes/(1024**3):.1f} GB"
    
    # 파일 트리 추가
    tree_section = f"""
📁 소스 구조
{'-'*40}
{source_path.name}/
"""
    tree_lines = create_file_tree(source_path)
    for line in tree_lines:
        tree_section += line + "\n"
    
    merged_content.append(tree_section + "\n")
    
    # 파일 내용 수집
    def collect_files(path: Path) -> list:
        """파일 리스트 수집"""
        files = []
        
        try:
            for item in path.rglob('*'):
                if item.is_file() and not should_exclude(item):
                    # Python 파일(.py) 확인
                    if item.suffix.lower() == '.py':
                        files.append(item)
        except Exception as e:
            print(f"⚠️ 파일 수집 중 오류: {e}")
        
        return sorted(files)
    
    files = collect_files(source_path)
    
    # 파일 통계 정보
    stats_section = f"""
📊 파일 통계
{'-'*40}
총 파일 수: {len(files)}
"""
    
    # 확장자별 통계
    ext_stats = {}
    total_size = 0
    
    for file_path in files:
        info = get_file_info(file_path)
        ext = info['extension'] or 'no extension'
        ext_stats[ext] = ext_stats.get(ext, 0) + 1
        total_size += info['size']
    
    for ext, count in sorted(ext_stats.items()):
        stats_section += f"  {ext}: {count}개\n"
    
    stats_section += f"총 파일 크기: {format_file_size(total_size)}\n\n"
    merged_content.append(stats_section)
    
    # 각 파일 내용 추가
    for file_path in files:
        try:
            relative_path = file_path.relative_to(source_path)
            file_info = get_file_info(file_path)
            
            # 파일 헤더
            file_header = f"""
{'='*80}
📄 파일: {relative_path}
{'='*80}
크기: {format_file_size(file_info['size'])}
수정일: {file_info['modified']}
경로: {file_path.absolute()}
{'='*80}

"""
            merged_content.append(file_header)
            
            # 파일 내용 읽기
            try:
                with open(file_path, 'r', encoding=encoding, errors='ignore') as f:
                    content = f.read()
                    
                    # 빈 파일 처리
                    if not content.strip():
                        merged_content.append("(빈 파일)\n\n")
                    else:
                        merged_content.append(content)
                        if not content.endswith('\n'):
                            merged_content.append('\n')
                        merged_content.append('\n')
                    
                    # 통계 업데이트
                    file_count += 1
                    total_lines += len(content.splitlines())
                    
            except Exception as e:
                error_msg = f"❌ 파일 읽기 실패: {e}\n\n"
                merged_content.append(error_msg)
                print(f"⚠️ 파일 읽기 실패: {file_path} - {e}")
                
        except Exception as e:
            print(f"⚠️ 파일 처리 실패: {file_path} - {e}")
            continue
    
    # 최종 통계 추가
    footer = f"""
{'='*80}
📈 통합 완료 통계
{'='*80}
소스명: {source_path.name}
처리된 파일 수: {file_count}
총 라인 수: {total_lines:,}
생성 파일: {output_file}
처리 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
{'='*80}
"""
    merged_content.append(footer)
    
    # 결과 파일 저장
    try:
        with open(output_file, 'w', encoding=encoding) as f:
            f.write(''.join(merged_content))
        
        print(f"✅ Python 파일 통합 완료!")
        print(f"   📁 소스명: {source_path.name}")
        print(f"   📂 대상 경로: {source_path.absolute()}")
        print(f"   📄 출력 파일: {Path(output_file).absolute()}")
        print(f"   📊 통합 파일: {file_count}개")
        print(f"   📏 총 라인 수: {total_lines:,}")
        print(f"   💾 파일 크기: {format_file_size(Path(output_file).stat().st_size)}")
        
        return True
        
    except Exception as e:
        print(f"❌ 파일 저장 실패: {e}")
        return False

def main():
    """메인 실행 함수"""
    
    # 사용법 출력
    if len(sys.argv) < 2 or sys.argv[1] in ['-h', '--help']:
        print(f"""
🔧 Python 소스 파일 통합 도구

사용법:
    python {sys.argv[0]} <소스_루트_디렉토리> [출력_파일명]

예시:
    python {sys.argv[0]} my-python-project
    python {sys.argv[0]} ./backend-service my_merged_python.txt
    python {sys.argv[0]} /path/to/python-source

매개변수:
    소스_루트_디렉토리     : 통합할 Python 소스의 루트 디렉토리 경로 (필수)
    출력_파일명           : 통합 결과 파일명 (선택, 미지정시 자동 생성)

지원 파일 형식:
    Python 파일: .py
""")
        return
    
    # 명령행 인자 처리
    source_root = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    print(f"🚀 Python 소스 파일 통합 시작")
    print(f"   📁 Python 소스 루트 디렉토리: {source_root}")
    print(f"   📄 출력 파일: {output_file or '자동 생성'}")
    print(f"   {'='*50}")
    
    success = merge_source_files(source_root, output_file)
    
    if success:
        print(f"\n🎉 통합 성공!")
    else:
        print(f"\n❌통합 실패!")
        sys.exit(1)

if __name__ == "__main__":
    main()

