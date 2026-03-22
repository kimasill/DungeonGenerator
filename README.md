# PCGDungeonGenerator

**Unreal Engine 5.6+ Procedural Dungeon Generator Plugin**
PCGDungeonGenerator는 언리얼 엔진의 **PCG/PCGEx** 시스템을 활용해 다층 구조의 던전을 자동으로 생성하고, 다양한 파라미터와 데이터 에셋을 기반으로 구조물 및 오브젝트를 배치할 수 있도록 하는 플러그인입니다.

---

## 주요 기능 (Features)

* **던전 구조 생성**

  * 다층 구조(Levels) 및 층간 간격(Level Spacing)
  * 벽, 문, 창문, 통로, 천장, 사잇돌, 기둥 자동 배치
  * 외곽(Exterior/Inner) 벽체 옵션
  * 다양한 계단 모드(직선, ㄴ자, ㄷ자, Z자 형태)

* **오브젝트 배치 시스템**

  * **오브젝트 생성관련 수십개의 옵션** + **가중치 시스템** 기반
  * Placement Mode (Floor, Wall, Corner, Window 등)
  * Facing Mode (Origin, AgainstWall, AlongWall 등)
  * Clearance, Region 제한(Room/Corridor/Any)
  * Container/Children 방식의 자식 오브젝트 재귀 생성

* **Depth 기반 재귀적 오브젝트 생성**

  * `Object Creation Depth` 값에 따라 부모-자식 오브젝트 자동 생성
  * FeedBack Loop 방식으로 Children/Interior Points 생성

* **랜덤성 제어**

  * Seed 기반 구조 및 오브젝트 생성
  * Weight, Empty 값으로 확률적 배치 조절

* **샘플 맵 제공**

  * `/PCGDungeonGenerator/Maps/PCG_Mension`

---

## 설치 (Installation)

1. `Plugins` 폴더에 `PCGDungeonGenerator` 복사
2. 언리얼 에디터 실행 후 `Edit → Plugins`에서 **PCGDungeonGenerator** 활성화
3. 필요 시 `PCG`, `PCGEx` 플러그인도 함께 Enable

---

## 사용법 (Usage)

1. **레벨에 블루프린트 배치**

   * `BP_Dungeon` 액터를 레벨에 추가
   * 기본적으로 `PCG_MultiFloorDungeon`이 연결됨

2. **데이터 에셋 입력**

   * `/PCGDungeonGenerator/PCG/DataAssets/Data/` 폴더의 `PDA_` 접두 블루프린트에서 변수 입력
   * 입력값에 따라 구조와 오브젝트가 생성됨

3. **샘플 맵 실행**

   * `/PCGDungeonGenerator/Maps/PCG_Mension` 확인
   * 미리 설정된 던전 구조와 배치 확인 가능

---

## 주요 설정 (Configuration)

### 5-1. 메인 설정 (`BP_Dungeon`)

* **Level**: 층 개수
* **Level Spacing**: 층간 거리
* **Unique Floor Interval / Offset**: 레이어별 디테일 제어
* **Cell Size**: 셀 크기 (벽, 바닥 단위)
* **Minimum Cell Count**: 방 최소 크기
* **Grid Scale**: 그리드 범위
* **Seed**: 랜덤 시드
* **Door Frame Size**: 문 프레임 셀 크기
* **Stair Options**: 계단 모드, StairRiser, Stretch, MaxStair
* **Corner Size**: 코너 기둥 크기
* **Object Creation Depth**: 오브젝트 재귀 생성 횟수

### 5-2. 구조 오브젝트 (`DA_RegularBuilding`)

* **OpenBack**: 뒷면 생성 여부
* **MaintenanceMode**: Snap/Scaling 모드

### 5-3. 오브젝트 옵션 (`DA_Object`)

* **Mesh / Actor**: 메시 또는 블루프린트 지정
* **BPOnly**: 메시 없이 블루프린트만 생성
* **Placement Mode**: 오브젝트 배치 위치 지정 (예: Floor, Wall, Corner)
* **Facing**: 배치 방향 (Origin, AgainstWall 등)
* **Weight / Empty**: 생성 확률 및 제거 확률
* **Clearance**: 여유 공간 설정
* **Container / Children Object**: 자식 오브젝트 배치 방식

---

## Depth 로직 (Recursive Object Generation)

* 오브젝트가 그리드를 생성 → 포인트 생성
* 포인트는 **FeedBack Loop**를 통해 다음 루프에서 재사용
* Depth 수치만큼 반복 실행되어 부모-자식 오브젝트 재귀 배치
* 부모 오브젝트 인덱스(TargetObjectIndex)로 특정 오브젝트를 자식으로 지정 가능

![Depth Graph](docs/images/depth-graph.png)

---

## 프로젝트 구조

```
PCGDungeonGenerator/
 ├── PCGDungeonGenerator.uplugin
 ├── Content/
 │   ├── Maps/
 │   │   └── PCG_Mension.umap
 │   ├── PCG/
 │   │   ├── BP_Dungeon.uasset
 │   │   ├── DataAssets/
 │   │   │   ├── DA_RegularBuilding.uasset
 │   │   │   ├── DA_Object.uasset
 │   │   │   └── Data/
 │   │   │       └── PDA_*.uasset
 │   └── Materials, Meshes, etc.
 └── Resources/
     └── Icon128.png
```

---

## 의존성 (Dependencies)

* **PCG Plugin**
* **PCGEx Plugin**

---

## 라이선스 (License)

> MIT License

---

## 📞 연락처 (Contact)

* **GitHub**: [kimasill](https://github.com/kimasill?tab=repositories)
* **Discord**: [Community Link](https://discord.gg/xgSzWR3Rf6)

