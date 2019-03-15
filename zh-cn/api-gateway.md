# API网关

Gateway 是基于 http-proxy 实现的一个简单 API 网关

## 安装

```bash
npm install @nestcloud/gateway --save
```

## 注册模块

```typescript
import { Module } from '@nestjs/common';
import { GatewayModule } from "@nestcloud/gateway";
import { NEST_BOOT } from '@nestcloud/common';

@Module({
    imports: [
        GatewayModule.register({dependencies: [NEST_BOOT]}),
    ]
})
export class AppModule {
}
```

## Boot 配置

```yaml
gateway:
  routes:
    - id: user
      uri: lb://nestcloud-user-service
    - id: pay
      uri: https://example.com/pay
```

## 如何使用

```typescript
import { All, Controller, Param, Req, Res } from "@nestjs/common";
import { Request, Response } from 'express';
import { Gateway, InjectGateway } from "@nestcloud/gateway";

@Controller('/gateway/:service')
export class GatewayController {
    constructor(
        @InjectGateway() private readonly gateway: Gateway,
    ) {
    }

    @All()
    do(@Req() req: Request, @Res() res: Response, @Param('service') id) {
        this.gateway.forward(req, res, id);
    }
}
```

## 注意

使用该模块需要禁用 body parser 中间件，否则 put post 请求会 pending。

```typescript
const app = await NestFactory.create(AppModule, { bodyParser: false });
```

## TODO

支持过滤器 \(filter\)

