# 빌드 환경 설정
FROM gradle:7.3.3-jdk17 AS build

# 작업 디렉토리 설정
WORKDIR /app

# Gradle Wrapper 관련 파일과 소스 코드 복사
COPY . .

# Gradle Wrapper를 사용하여 애플리케이션 빌드 (테스트 제외)
RUN ./gradlew build --no-daemon -x test

# 실행 환경 설정
FROM openjdk:17-slim

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 단계에서 생성된 JAR 파일을 정확히 복사
COPY --from=build /app/build/libs/travelcommerce-0.0.1-SNAPSHOT.jar app.jar

# 애플리케이션 실행
ENTRYPOINT ["java","-jar","/app/app.jar"]

# 컨테이너 포트 설정
EXPOSE 8090
