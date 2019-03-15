# 日志

Logger 提供日志功能，基于 winston@2 实现。

## 安装

```bash
npm install @nestcloud/logger --save
```

## 注册模块

```typescript
import { Module } from '@nestjs/common';
import { LoggerModule, Logger } from '@nestcloud/logger';

Logger.contextPath = __dirname;
Logger.filename = 'logger.yml';

@Module({
  imports: [
      LoggerModule.register()
  ],
})
export class ApplicationModule {}
```

## 配置

```yaml
logger:
  level: info
  transports:
    - transport: console
      level: debug
      colorize: true
      datePattern: YYYY-MM-DD h:mm:ss
      label: user-service
    - transport: file
      name: info
      filename: info.log
      datePattern: YYYY-MM-DD h:mm:ss
      label: user-service
      # 100M
      maxSize: 104857600
      json: false
      maxFiles: 10
    - transport: dailyRotateFile
      filename: info.log
      datePattern: YYYY-MM-DD-HH
      zippedArchive: true
      maxSize: 20m
      maxFiles: 14d
```

## 使用

```typescript
import { Injectable } from '@nestjs/common';
import { InjectLogger, Logger } from '@nestcloud/logger';
import { LoggerInstance } from 'winston';

@Injectable()
export class TestService {
  constructor(@InjectLogger() private readonly logger: LoggerInstance) {}

  log() {
      this.logger.info('The first log');
  }
}
```

## 自定义 NestJS 日志

```typescript
import { NestFactory } from '@nestjs/core'
import { Injectable } from '@nestjs/core';
import { NestLogger, Logger } from '@nestcloud/logger';
import { AppModule } from './app.module';

Logger.contextPath = __dirname;
Logger.filename = 'logger.yml';

async function bootstrap() {
  const app = await NestFactory.create(AppModule, { 
      logger: new NestLogger()
  });
}
```

## 自定义 Typeorm 日志

```typescript
import { Module } from '@nestjs/common';
import { TypeormLogger } from '@nestcloud/logger';
import { TypeOrmModule } from '@nestjs/typeorm';

@Module({
  imports: [
      TypeOrmModule.forRootAsync({
          useFactory: () => ({
              /* ... */
              logger: new TypeormLogger(),
          }),
          inject: [],
      })
  ],
})
export class ApplicationModule {}
```
