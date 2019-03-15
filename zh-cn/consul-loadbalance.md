# 负载均衡

Consul-Loadbalance 提供本地负载均衡功能，目前支持的负载均衡策略有：随机（默认），轮询，加权。

## 安装

```bash
npm install consul @nestcloud/consul @nestcloud/consul-service @nestcloud/consul-loadbalance --save
```

## 注册模块

```typescript
import { Module } from '@nestjs/common';
import { ConsulModule } from '@nestcloud/consul';
import { ConsulServiceModule } from '@nestcloud/consul-service';
import { LoadbalanceModule } from '@nestcloud/consul-loadbalance';
import { BootModule } from '@nestcloud/boot';
import { NEST_BOOT } from '@nestcloud/common';

@Module({
  imports: [
      ConsulModule.register({dependencies: [NEST_BOOT]}),
      BootModule.register(__dirname, 'bootstrap.yml'),
      ConsulServiceModule.register({ dependencies: [NEST_BOOT] }),
      LoadbalanceModule.register({ dependencies: [NEST_BOOT] }),
  ],
})
export class ApplicationModule {}
```

## Boot 配置

```yaml
loadbalance:
  # global rule
  ruleCls: RandomRule
  rules:
    - {service: 'test-service', ruleCls: 'RandomRule'}
    - {service: 'user-service', ruleCls: '../rules/CustomRule'}
```

## 如何使用

```typescript
import { Injectable } from '@nestjs/common';
import { Loadbalance, InjectLoadbalancee } from '@nestcloud/consul-loadbalance';

@Injectable()
export class TestService {
  constructor(
      @InjectLoadbalancee() private readonly lb: Loadbalance
  ) {}
  
  test() {
      const node = this.lb.choose('test-service');
  }
}
```

## 如何自定义负载均衡策略

```typescript
import { Rule, Loadbalancer } from '@nestcloud/consul-loadbalance';

export class MasterRule implements Rule {
    private loadbalancer: Loadbalancer;
    
    init(loadbalancer: Loadbalancer) {
        this.loadbalancer = loadbalancer;
    }

    choose() {
        const servers = this.loadbalancer.servers;
        if(servers.length) {
            return servers[0];
        }
        return null;
    }
}
```

## API 文档

### class LoadbalanceModule

#### static register\(options\): DynamicModule

注册 loadbalance 模块

| field | type | description |
| :--- | :--- | :--- |
| options.dependencies | string\[\] | 如果 dependencies 设置为 \[NEST\_BOOT\]，则通过 @nestcloud/boot 模块获取配置，无需配置以下参数 |
| options.ruleCls | string \| class | 负载均衡策略，支持：RandomRule，RoundRobinRule，WeightedResponseTimeRule 或者使用自定义策略，填写策略class文件的相对路径 |
| options.rules | RuleOption | 分别为不同的服务配置不同的负载均衡策略，例如：\[{service: '', ruleCls: ''}\] |

### class Loadbalance

#### choose\(service: string\): Server

获取运行某服务的某台服务器。

| field | type | description |
| :--- | :--- | :--- |
| service | string | 服务名称 |

#### chooseLoadbalancer\(service: string\): Loadbalancer

获取 loadbalancer, 可以通过该对象操作运行某服务的服务器列表，例如添加修改删除等。

| field | type | description |
| :--- | :--- | :--- |
| service | string | 服务名称 |

