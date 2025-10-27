# GradleWrapper생성가이드

Java 버전을 확인하고 호환되는 Gradle Wrapper를 자동으로 생성해주세요.

## 작업 단계

### 1단계: Java 버전 확인
- `java -version` 명령으로 현재 Java 버전 확인
- Major 버전 추출 (예: 23, 21, 17, 11, 8)

### 2단계: Gradle 버전 결정
Java 버전에 맞는 Gradle 버전 선택:
- Java 23 → Gradle 8.10.2+
- Java 21 → Gradle 8.5+
- Java 17 → Gradle 7.5+
- Java 11 → Gradle 7.0+
- Java 8 → Gradle 6.0+

### 3단계: Gradle Wrapper 생성

시스템에 Gradle이 설치되어 있으면:
```bash
gradle wrapper --gradle-version {결정된버전}
```

Gradle이 없으면 수동 생성:

#### 3-1. 디렉토리 생성
```bash
mkdir -p gradle/wrapper
```

#### 3-2. gradle-wrapper.properties 파일 생성
```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-{VERSION}-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

#### 3-3. gradle-wrapper.jar 다운로드
```bash
curl -L -o gradle/wrapper/gradle-wrapper.jar \
  https://raw.githubusercontent.com/gradle/gradle/v{VERSION}/gradle/wrapper/gradle-wrapper.jar
```

#### 3-4. gradlew 스크립트 다운로드 및 실행 권한 부여
```bash
# Linux/Mac
curl -L -o gradlew https://raw.githubusercontent.com/gradle/gradle/v{VERSION}/gradlew
chmod +x gradlew

# Windows
curl -L -o gradlew.bat https://raw.githubusercontent.com/gradle/gradle/v{VERSION}/gradlew.bat
```

### 4단계: 검증
```bash
./gradlew --version
```

### 5단계: 결과 보고
- 생성된 Gradle 버전 확인
- Java 버전과 호환성 확인
- 테스트 빌드 수행 (`./gradlew clean build`)

## 주의사항
- {VERSION}을 실제 버전 번호로 교체 (예: 8.10.2)
- 네트워크 연결 필요
- Windows에서는 `./gradlew` 대신 `.\gradlew.bat` 사용
