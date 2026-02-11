# ================================
# Stage 1: build JAR
# ================================
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /build

COPY pom.xml ./
COPY backend/ backend/

# Build (skip tests for faster image build; run tests in CI)
RUN mvn -B package -DskipTests

# ================================
# Stage 2: runtime
# ================================
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Non-root user
RUN adduser -D -u 1000 appuser

COPY --from=builder /build/target/*.jar app.jar

# Upload dir (will be mounted or created)
RUN mkdir -p /app/data/uploads && chown -R appuser:appuser /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
