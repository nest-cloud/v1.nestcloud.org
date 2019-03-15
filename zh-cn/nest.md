# 如何使用 NestCloud

## 安装组件

```bash
npm install --save \
    @nestcloud/common \
    @nestcloud/boot \
    @nestcloud/consul \ 
    @nestcloud/consul-service \
    @nestcloud/consul-config \ 
    @nestcloud/consul-loadbalance \ 
    @nestcloud/feign \
    @nestcloud/logger \ 
    @nestcloud/schedule 
```

### main.ts

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { Boot } from 'nest-boot';
import { NestLogger, Logger } from '@nestcloud/logger';

Logger.contextPath = __dirname;
const configFilename = Logger.filename = 'bootstrap.yaml';

async function bootstrap() {
    const boot = new Boot(__dirname, configFilename);
    const app = await NestFactory.create(AppModule, { logger: new NestLogger() });
    await app.listen(boot.get('web.port', 3000));
}

bootstrap();
```

### app.module.ts

```typescript
import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TerminusModule } from '@nestjs/terminus';
import { DatabaseHealthIndicator, TerminusModule, TerminusModuleOptions } from "@nestjs/terminus";

import { NEST_BOOT, NEST_CONSUL_LOADBALANCE, NEST_CONSUL_CONFIG, NEST_CONSUL_CONFIG_PROVIDER } from '@nestcloud/common';
import { BootModule } from '@nestcloud/boot';
import { ConsulModule } from '@nestcloud/consul';
import { ConsulConfigModule } from '@nestcloud/consul-config';
import { ConsulServiceModule } from '@nestcloud/consul-service';
import { LoadbalanceModule } from '@nestcloud/consul-loadbalance';
import { FeignModule } from '@nestcloud/feign';
import { LoggerModule, TypeormLogger } from '@nestcloud/logger';


@Module({
    imports: [
        LoggerModule.register(),
        BootModule.register(__dirname, `bootstrap.yaml`),
        ConsulModule.register({ dependencies: [NEST_BOOT] }),
        ConsulConfigModule.register({ dependencies: [NEST_BOOT] }),
        ConsulServiceModule.register({ dependencies: [NEST_BOOT] }),
        LoadbalanceModule.register({ dependencies: [NEST_CONSUL_CONFIG] }),
        FeignModule.register({ dependencies: [NEST_CONSUL_LOADBALANCE] }),
        TerminusModule.forRootAsync({
            inject: [DatabaseHealthIndicator],
            useFactory: (db: DatabaseHealthIndicator) => ({
                endpoints: [{
                    url: '/health',
                    healthIndicators: [
                        async () => db.pingCheck('database', { timeout: 300 }),
                    ],
                }],
            }),
        }),
        TypeOrmModule.forRootAsync({
            useFactory: (config: ConsulConfig) => ({
                type: 'mysql',
                host: config.get('dataSource.host', 'localhost'),
                port: config.get('dataSource.port', 3306),
                username: config.get('dataSource.username', 'root'),
                password: config.get('dataSource.password', ''),
                database: config.get('dataSource.database', 'cloud-service'),
                entities: [__dirname + '/entities/*{.ts,.js}'],
                synchronize: config.get('dataSource.synchronize', false),
                maxQueryExecutionTime: config.get('dataSource.maxQueryExecutionTime', 1000),
                logging: ['error', 'warn'],
                logger: new TypeormLogger(),
            }),
            inject: [NEST_CONSUL_CONFIG_PROVIDER],
        })
    ]
})
export class AppModule {
}
```

### bootstrap.yaml

请查看 [Boot完整配置](/zh-cn/config)
