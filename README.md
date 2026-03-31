# DungeonGenerator — UE5 PCG 던전 생성 플러그인

<p align="center">
  <a href="https://github.com/kimasill/DungeonGenerator"><img alt="GitHub Repo" src="https://img.shields.io/badge/GitHub-DungeonGenerator-181717?style=for-the-badge&logo=github&logoColor=white" /></a>
  <img alt="Unreal Engine" src="https://img.shields.io/badge/Unreal%20Engine-5.6+-0E1128?style=for-the-badge&logo=unrealengine&logoColor=white" />
  <img alt="PCG" src="https://img.shields.io/badge/PCG-Plugin-2EA44F?style=for-the-badge" />
  <a href="https://pcgex.gitbook.io/pcgex/home" target="_blank" rel="noopener noreferrer"><img alt="PCGEx" src="https://img.shields.io/badge/PCGEx-Extension-5865F2?style=for-the-badge" /></a>
</p>

<p align="center">
  <a href="https://kimasill.github.io/projects/pcg-dungeon.html" target="_blank" rel="noopener noreferrer">
    <img src="https://kimasill.github.io/images/PCGdungeon/Title.png" alt="PCG Dungeon" width="720" />
  </a>
</p>

> 던전 파밍형 게임을 위한 **절차적 레벨 생성** UE5 PCG 플러그인입니다. 그래프·파이프라인 세부는 아래 **Notion 가이드**에서 확인할 수 있습니다.

---

## 한눈에 보기

| 항목 | 내용 |
| --- | --- |
| 형태 | Unreal Engine 5 플러그인 |
| 플랫폼 | PC |
| 규모 | 1인 · 약 2개월 |
| 역할 | 플러그인 아키텍처, PCG 그래프 설계, 절차적 시스템 |
| 스택 | UE 5.6+ · [PCG](https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-framework) · [PCGEx](https://pcgex.gitbook.io/pcgex/home) |

---

## 링크

| 구분 | URL |
| --- | --- |
| Trailer (YouTube) | [YouTube에서 보기](https://www.youtube.com/watch?v=cgXfvvlb2Uk) |
| PCG 그래프·파이프라인 가이드 (Notion) | [PCG Guide – Full Graph & Pipeline](https://www.notion.so/322ba0befb31807b92c4e46433b5936e?v=322ba0befb31803da6af000c820b1cd6&source=copy_link) |
| 동일 가이드 (Notion Site) | [가이드 문서 보러가기](https://oxidized-conifer-aae.notion.site/322ba0befb31807b92c4e46433b5936e?v=322ba0befb31803da6af000c820b1cd6&source=copy_link) |
| PCGEx 문서 | [PCGEx GitBook](https://pcgex.gitbook.io/pcgex/home) · [예제 프로젝트](https://pcgex.gitbook.io/pcgex/working-with-pcgex/getting-started/example-project) |
| 웹 포트폴리오 | [pcg-dungeon.html](https://kimasill.github.io/projects/pcg-dungeon.html) |

---

## 핵심 기능

### 1. 그래프 기반 레이아웃

그리드 그래프를 생성한 뒤 MST(최소 신장 트리)로 분기 없이 모든 방이 연결된 던전 골격을 만듭니다.

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EA%B7%B8%EB%9E%98%ED%94%84.png" alt="그래프 레이아웃" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EA%B7%B8%EB%9E%98%ED%94%842.png" alt="그래프 레이아웃 2" width="380" />
</p>

### 2. 다층 던전 & 계단 시스템

계단 시스템으로 층간 연결. ㄴ/ㄷ/직선형 등 계단 규칙을 정의해서 자연스러운 수직 연결을 생성합니다.

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EB%A9%98%EC%85%98-%EA%B3%84%EB%8B%A8.png" alt="계단 시스템" width="640" />
</p>

### 3. 구조물 파이프라인

방·복도·벽·문 등을 규칙 기반으로 배치합니다. Object Splitter가 그리드를 분할하고, 방향·충돌·가중치·생성 순서에 따라 Floor/Wall/Ceiling/Corner 등으로 분류합니다.

### 4. DataAsset 구동

Seed, 그리드 규모, 생성 Depth 등을 에셋으로 분리합니다. 동일 구조로 Mansion / 게임룸 등 테마만 교체하면 전혀 다른 분위기가 됩니다.

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EB%8D%B0%EC%9D%B4%ED%84%B0%EC%B2%98%EB%A6%AC.png" alt="DataAsset 파이프라인" width="560" />
</p>

---

## 생성 결과

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%97%94%EC%A7%84%EB%A3%B8-%EB%AC%B8.png" alt="엔진룸 문" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%97%94%EC%A7%84%EB%A3%B8-%EA%B5%AC%EC%A1%B0.png" alt="엔진룸 구조" width="380" />
</p>

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EB%A9%98%EC%85%98.png" alt="Mansion 테마" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EA%B2%8C%EC%9E%84%EB%A3%B8.png" alt="게임룸 테마" width="380" />
</p>

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%97%94%EC%A7%84%EB%A3%B8-%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8.png" alt="엔진룸 오브젝트" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EB%A9%98%EC%85%98-%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8.png" alt="멘션 오브젝트" width="380" />
</p>

*동일 플러그인, 동일 그래프 — DataAsset만 교체해서 엔진룸 / Mansion / 게임룸 테마를 생성한 결과*

---

## 아키텍처 개요

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%95%84%ED%82%A4%ED%85%8D%EC%B2%98.png" alt="PCG Pipeline Architecture" width="720" />
</p>

```text
PCG Graph Pipeline (요약)
─────────────────────────────────────────
1. Grid Graph 생성 → MST 연결
2. Room / Corridor 분류 (노드 타입)
3. 구조물 배치 (Wall, Floor, Door 규칙)
4. Object Splitter → 방향/충돌 기반 배치
5. DataAsset으로 Seed·그리드 규모·Depth 제어
─────────────────────────────────────────
  → 테마 교체: DataAsset만 Swap
  → 다층: 계단 규칙 → 층간 노드 연결
```

---

## Getting Started

1. 플러그인 폴더를 프로젝트의 `Plugins/` 아래에 둡니다.
2. UE 에디터에서 **Edit → Plugins**에서 본 플러그인을 활성화합니다.
3. **PCG**, **PCGEx** 플러그인을 함께 켜 두었는지 확인합니다.
4. 샘플 맵·DataAsset을 열어 Seed·그리드·에셋 교체 결과를 확인합니다.

> 노드별 의미·그래프 전체 흐름은 **Notion 가이드**를 참고하는 것을 권장합니다.
