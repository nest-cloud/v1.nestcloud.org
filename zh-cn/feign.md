# Http 客户端

Feign 是支持负载均衡和装饰器的 http 客户端，使用更加简单，快捷。

## 安装

```bash
npm install @nestcloud/feign --save
```

## 注册模块

```typescript
import { Module } from '@nestjs/common';
import { ConsulModule } from '@nestcloud/consul';
import { ConsulServiceModule } from '@nestcloud/consul-service';
import { LoadbalanceModule } from '@nestcloud/consul-loadbalance';
import { BootModule } from '@nestcloud/boot';
import { FeignModule } from '@nestcloud/feign';
import { NEST_BOOT, NEST_CONSUL_LOADBALANCE } from '@nestcloud/common';

@Module({
  imports: [
      ConsulModule.register({dependencies: [NEST_BOOT]}),
      BootModule.register(__dirname, 'bootstrap.yml'),
      ConsulServiceModule.register({ dependencies: [NEST_BOOT] }),
      LoadbalanceModule.register({ dependencies: [NEST_BOOT] }),
      FeignModule.register({ dependencies: [NEST_CONSUL_LOADBALANCE] }),
  ],
})
export class ApplicationModule {}
```

## 如何使用

```typescript
import { Injectable } from "@nestjs/common";
import { Loadbalanced, Get, Query, Post, Body, Param, Put, Delete } from "@nestcloud/feign";

@Injectable()
@Loadbalanced('user-service') // 开启负载均衡支持
export class UserClient {
    @Get('/users')
    getUsers(@Query('role') role: string) {
    }
    
    @Get('http://test.com/users')
    @Loadbalanced(false) // 关闭负载均衡支持
    getRemoteUsers() {
    }
    
    @Post('/users')
    createUser(@Body('user') user: any) {
    }
    
    @Put('/users/:userId')
    updateUser(@Param('userId') userId: string, @Body('user') user: any) {
    }
    
    @Delete('/users/:userId')
    deleteUser(@Param('userId') userId: string) {
       
    }
}
```

## API 文档

### Get\|Post\|Put\|Delete\|Options\|Head\|Patch\|Trace\(uri: string, options?: AxiosRequestConfig\): MethodDecorator

装饰 Http Method

| field | type | description |
| :--- | :--- | :--- |
| uri | string | 请求的URL |
| options | object | axios 配置，详情请查看 axios 文档 |

### Param\|Body\|Query\|Header\(field?: string\): ParameterDecorator

装饰请求参数

| field | type | description |
| :--- | :--- | :--- |
| field | string | 字段名称 |

### SetHeader\|SetQuery\|SetParam\|SetBody\(field: string, value: any\): MethodDecorator

装饰常量请求参数

| field | type | description |
| :--- | :--- | :--- |
| field | string | 字段名称 |
| value | string \| number \| object | 字段对应的值 |

### Response\(\): MethodDecorator

返回完整的 http response 对象

### ResponseHeader\(\): MethodDecorator

返回 http header 对象

### ResponseBody\(\): MethodDecorator

返回 http body，默认，可以不加

### ResponseType\(type: string\): MethodDecorator

设置返回值类型，例如：arraybuffer，blob，document，json，text，stream，作用在函数上，默认是 json

### ResponseEncode\(type: string\): MethodDecorator

设置返回值编码，默认是 utf8

### Loadbalanced\(service: string \| boolean\): ClassDecorator \| MethodDecorator

开启或者关闭负载均衡支持

### Interceptor&lt;T extends IInterceptor&gt;\(interceptor: { new\(\): T }\)

添加拦截器，例如：

AddHeaderInterceptor.ts

```typescript
import { IInterceptor } from "@nestcloud/feign";
import { AxiosResponse, AxiosRequestConfig } from 'axios';

export class AddHeaderInterceptor implements IInterceptor {
    onRequest(request: AxiosRequestConfig): AxiosRequestConfig {
        request.headers['x-service'] = 'service-name';
        return request;
    }
    
    onResponse(response: AxiosResponse): AxiosResponse {
        return response;
    }
    
    onRequestError(error: any): any {
        return Promise.reject(error);
    }
    
    onResponseError(error: any): any {
        return Promise.reject(error);
    }
}
```

ArticleClient.ts

```typescript
import { Injectable } from "@nestjs/common";
import { Get, Interceptor } from "@nestcloud/feign";
import { AddHeaderInterceptor } from "./middlewares/AddHeaderInterceptor";

@Injectable()
@Interceptor(AddHeaderInterceptor)
export class ArticleClient {
    @Get('https://api.apiopen.top/recommendPoetry')
    getArticles() {
    }
}
```
{% endcode-tabs-item %}
{% endcode-tabs %}

中间件执行过程：

```typescript
@Interceptor(Interceptor1)
@Interceptor(Interceptor2)
export class Client {

    @Interceptor(Interceptor3)
    @Interceptor(Interceptor4)
    getArticles() {
    }
}
```

执行结果：

```text
interceptor1 request
interceptor2 request
interceptor3 request
interceptor4 request
interceptor4 response
interceptor3 response
interceptor2 response
interceptor1 response
```

