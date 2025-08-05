#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Tripgen Service Runner Script
Reads execution profiles from .idea/workspace.xml and runs services accordingly.

Usage:
    python run-config.py <service-name>

Examples:
    python run-config.py user-service
    python run-config.py location-service
    python run-config.py trip-service
    python run-config.py ai-service
"""

import os
import sys
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
import argparse


def get_project_root():
    """Find project root directory"""
    current_dir = Path(__file__).parent.absolute()
    while current_dir.parent != current_dir:
        if (current_dir / 'gradlew').exists() or (current_dir / 'gradlew.bat').exists():
            return current_dir
        current_dir = current_dir.parent
    
    # If gradlew not found, assume parent directory of develop as project root
    return Path(__file__).parent.parent.absolute()


def parse_workspace_xml(project_root):
    """Parse workspace.xml file to extract execution profile information"""
    workspace_xml_path = project_root / '.idea' / 'workspace.xml'
    
    if not workspace_xml_path.exists():
        print(f"[ERROR] Cannot find workspace.xml file: {workspace_xml_path}")
        return {}
    
    try:
        tree = ET.parse(workspace_xml_path)
        root = tree.getroot()
        
        # Find RunManager component
        run_manager = root.find('.//component[@name="RunManager"]')
        if run_manager is None:
            print("[ERROR] Cannot find RunManager component")
            return {}
        
        configurations = {}
        
        # Find Gradle execution configurations
        for config in run_manager.findall('.//configuration[@type="GradleRunConfiguration"]'):
            config_name = config.get('name')
            if not config_name:
                continue
            
            # Extract environment variables
            env_vars = {}
            env_option = config.find('.//option[@name="env"]')
            if env_option is not None:
                env_map = env_option.find('map')
                if env_map is not None:
                    for entry in env_map.findall('entry'):
                        key = entry.get('key')
                        value = entry.get('value')
                        if key and value:
                            env_vars[key] = value
            
            # Extract task names
            task_names = []
            task_names_option = config.find('.//option[@name="taskNames"]')
            if task_names_option is not None:
                task_list = task_names_option.find('list')
                if task_list is not None:
                    for option in task_list.findall('option'):
                        value = option.get('value')
                        if value:
                            task_names.append(value)
            
            if env_vars or task_names:
                configurations[config_name] = {
                    'env_vars': env_vars,
                    'task_names': task_names
                }
        
        return configurations
    
    except ET.ParseError as e:
        print(f"[ERROR] workspace.xml parsing error: {e}")
        return {}
    except Exception as e:
        print(f"[ERROR] workspace.xml reading error: {e}")
        return {}


def get_gradle_command(project_root):
    """Return appropriate Gradle command for OS"""
    if os.name == 'nt':  # Windows
        gradle_bat = project_root / 'gradlew.bat'
        if gradle_bat.exists():
            return str(gradle_bat)
        return 'gradle.bat'
    else:  # Unix-like (Linux, macOS)
        gradle_sh = project_root / 'gradlew'
        if gradle_sh.exists():
            return str(gradle_sh)
        return 'gradle'


def run_service(service_name, config, project_root):
    """Run service"""
    print(f"[START] Starting {service_name} service...")
    
    # Set environment variables
    env = os.environ.copy()
    for key, value in config['env_vars'].items():
        env[key] = value
        print(f"   [ENV] {key}={value}")
    
    # Prepare Gradle command
    gradle_cmd = get_gradle_command(project_root)
    
    # Execute tasks
    for task_name in config['task_names']:
        print(f"\n[RUN] Executing: {task_name}")
        
        cmd = [gradle_cmd, task_name]
        
        try:
            # Execute from project root directory
            process = subprocess.Popen(
                cmd,
                cwd=project_root,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                bufsize=1,
                encoding='utf-8',
                errors='replace'
            )
            
            print(f"[CMD] Command: {' '.join(cmd)}")
            print(f"[DIR] Working directory: {project_root}")
            print("=" * 50)
            
            # Real-time output
            for line in process.stdout:
                print(line.rstrip())
            
            # Wait for process completion
            process.wait()
            
            if process.returncode == 0:
                print(f"\n[SUCCESS] {task_name} execution completed")
            else:
                print(f"\n[FAILED] {task_name} execution failed (exit code: {process.returncode})")
                return False
                
        except KeyboardInterrupt:
            print(f"\n[STOP] Interrupted by user")
            process.terminate()
            return False
        except Exception as e:
            print(f"\n[ERROR] Execution error: {e}")
            return False
    
    return True


def list_available_services(configurations):
    """List available services"""
    print("[LIST] Available services:")
    print("=" * 40)
    
    for service_name, config in configurations.items():
        if config['task_names']:
            print(f"  [SERVICE] {service_name}")
            for task in config['task_names']:
                print(f"     +-- {task}")
            print(f"     +-- {len(config['env_vars'])} environment variables")
        print()


def main():
    """Main function"""
    parser = argparse.ArgumentParser(
        description='Tripgen Service Runner Script',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python run-config.py user-service
    python run-config.py location-service
    python run-config.py trip-service
    python run-config.py ai-service
    python run-config.py --list
        """
    )
    
    parser.add_argument(
        'service_name',
        nargs='?',
        help='Service name to run'
    )
    
    parser.add_argument(
        '--list', '-l',
        action='store_true',
        help='List available services'
    )
    
    args = parser.parse_args()
    
    # Find project root
    project_root = get_project_root()
    print(f"[INFO] Project root: {project_root}")
    
    # Parse workspace.xml
    print("[INFO] Reading workspace.xml file...")
    configurations = parse_workspace_xml(project_root)
    
    if not configurations:
        print("[ERROR] No execution configurations found")
        return 1
    
    print(f"[INFO] Found {len(configurations)} execution configurations")
    
    # List services request
    if args.list:
        list_available_services(configurations)
        return 0
    
    # If service name not provided
    if not args.service_name:
        print("\n[ERROR] Please provide service name")
        list_available_services(configurations)
        print("Usage: python run-config.py <service-name>")
        return 1
    
    # Find service
    service_name = args.service_name
    if service_name not in configurations:
        print(f"[ERROR] Cannot find '{service_name}' service")
        list_available_services(configurations)
        return 1
    
    config = configurations[service_name]
    
    if not config['task_names']:
        print(f"[ERROR] No executable tasks found for '{service_name}' service")
        return 1
    
    # Execute service
    print(f"\n[TARGET] Starting '{service_name}' service execution")
    print("=" * 50)
    
    success = run_service(service_name, config, project_root)
    
    if success:
        print(f"\n[COMPLETE] '{service_name}' service started successfully!")
        return 0
    else:
        print(f"\n[FAILED] Failed to start '{service_name}' service")
        return 1


if __name__ == '__main__':
    try:
        exit_code = main()
        sys.exit(exit_code)
    except KeyboardInterrupt:
        print("\n[STOP] Interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n[ERROR] Unexpected error occurred: {e}")
        sys.exit(1)