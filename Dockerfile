FROM openjdk:17-jdk-slim
COPY target/hello-world-1.0-SNAPSHOT.jar /app/hello-world.jar
ENTRYPOINT ["java", "-jar", "/app/hello-world.jar"]
