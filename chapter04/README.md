# Yarn
## 개요
* hadoop cluster 자원 관리 시스템
* API 제공
    * 고수준 API

![https://d1jnx9ba8s6j9r.cloudfront.net/blog/wp-content/uploads/2018/06/Hadoop-v1.0-vs-Hadoop-v2.0.png](https://d1jnx9ba8s6j9r.cloudfront.net/blog/wp-content/uploads/2018/06/Hadoop-v1.0-vs-Hadoop-v2.0.png)

## Yarn 애플리케이션 수행
![https://static.packt-cdn.com/products/9781788999830/graphics/4ca83c2b-6e29-45d1-a15a-9674ba8cbae7.png](https://static.packt-cdn.com/products/9781788999830/graphics/4ca83c2b-6e29-45d1-a15a-9674ba8cbae7.png)

* resource manager: 클러스터 전체 자원의 사용량 관리
* node manager: 컨테이너 구동 및 모니터링
  > `컨테이너`란 단일 노드 내 리소스(memory)를 나타낸다. 하나의 MR 작업은 이러한 컨테이너 위에서 동작한다.
* Yarn 애플리케이션은 hadoop RPC와 같은 원격 호출 방식 이용
    * 상태 변경 전달
    * 클라이언트로부터 결과를 받음
    * **구체적인 방법은 application 마다 상이**
    > `RPC`란 원격 프로시저 호출은 별도의 원격 제어를 위한 코딩 없이 다른 주소 공간에서 함수나 프로시저를 실행할 수 있게하는 프로세스 간 통신 기술을 뜻한다.

### 자원 요청
* 컨테이너에 필요한 자원(cpu, mem) 의 용량 뿐 아니라 컨테이너의 지역성 제약도 표현

### 애플리케이션 수명
* app의 가장 단순한 유형은 사용자가 job 당 하나의 app 을 실행
* 혹은, job session 당 하나의 app 실행
    * job 사이 공유 데이터를 캐싱
    * ex. `Spark`
* 마지막은 장기 실행 app
    * ex. `apache slider`, `apache impala`

### 애플리케이션 생성
* [apache slider](http://incubator.apache.org/projects/slider.html)
    * [https://d2.naver.com/helloworld/1914772](https://d2.naver.com/helloworld/1914772)
* [apache twill](https://twill.apache.org/)

## Yarn / MR1 비교
* component
    * timeline server: app 이력 저장

|MapReduce1|Yarn|
|-----|-----|
|job tracker|resource manager, app master, timeline server|
|task tracker|node manager|
|슬롯|컨테이너|

* yarn 특징
    * 확장성
    * 가용성
    * 효율성
    * 멀티테넌시

## Yarn Scheduling
### Option
