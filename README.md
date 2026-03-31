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

<p align="center">
  <a href="https://www.youtube.com/watch?v=cgXfvvlb2Uk" title="PCG Dungeon Generator 시연 영상" target="_blank" rel="noopener noreferrer">
    <img src="https://img.youtube.com/vi/cgXfvvlb2Uk/maxresdefault.jpg" alt="PCG Dungeon Generator 시연 영상 (YouTube)" width="720" />
  </a>
</p>

> 던전 파밍형 게임을 위한 **절차적 레벨 생성**을 목표로 한 UE5 PCG 플러그인 레포지토리입니다. 시연 영상·키 피처·제작 스토리는 [프로젝트 페이지](https://kimasill.github.io/projects/pcg-dungeon.html)에서, 그래프·파이프라인 세부는 아래 **Notion 가이드**에서 확인하시면 됩니다.

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
| 시연 (YouTube) | [PCG Dungeon Generator 영상](https://www.youtube.com/watch?v=cgXfvvlb2Uk) |
| PCG 그래프·파이프라인 가이드 (Notion) | [PCG Guide – Full Graph & Pipeline](https://www.notion.so/322ba0befb31807b92c4e46433b5936e?v=322ba0befb31803da6af000c820b1cd6&source=copy_link) |
| 동일 가이드 (Notion Site) | [가이드 문서 보러가기](https://oxidized-conifer-aae.notion.site/322ba0befb31807b92c4e46433b5936e?v=322ba0befb31803da6af000c820b1cd6&source=copy_link) |
| PCGEx 문서 | [PCGEx GitBook](https://pcgex.gitbook.io/pcgex/home) · [예제 프로젝트](https://pcgex.gitbook.io/pcgex/working-with-pcgex/getting-started/example-project) |
| 웹 포트폴리오 (개요·Why PCG·레이아웃·오브젝트 파이프라인) | [pcg-dungeon.html](https://kimasill.github.io/projects/pcg-dungeon.html) |

---

## 핵심 기능 (개요)

- **그래프 기반 레이아웃**: 그리드 그래프 생성 후 MST로 분기 없이 모든 방이 연결된 던전 골격 생성
- **다층 던전**: 계단 시스템으로 층간 연결, ㄴ/ㄷ/직선형 등 계단 규칙 정의
- **구조물 생성**: 방·복도·벽·문 등 규칙 기반 파이프라인으로 배치
- **오브젝트 파이프라인**: Object Splitter 기반으로 그리드 분할·방향·충돌·가중치·생성 순서 설계, Floor/Wall/Ceiling/Corner 등 배치 모드·Depth 기반 재귀(부모→자식)로 변주
- **DataAsset 구동**: Seed, 그리드 규모, 생성 Depth 등을 에셋으로 분리해 테마 전환·튜닝 (동일 구조로 Mansion / 게임룸 등 테마 스왑)

---

## 레포지토리에서 확인할 것

- 플러그인 소스·콘텐츠 에셋·샘플 맵 구조
- PCG 그래프·DataAsset이 에디터에서 어떻게 연결되는지 (상세 노드 설명은 Notion 가이드 권장)

---

## 스크린샷 (요약)

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%97%94%EC%A7%84%EB%A3%B8-%EB%AC%B8.png" alt="엔진룸 문" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EC%97%94%EC%A7%84%EB%A3%B8-%EA%B5%AC%EC%A1%B0.png" alt="엔진룸 구조" width="380" />
</p>

<p align="center">
  <img src="https://kimasill.github.io/images/PCGdungeon/%EB%A9%98%EC%85%98.png" alt="Mansion 테마" width="380" />
  <img src="https://kimasill.github.io/images/PCGdungeon/%EA%B2%8C%EC%9E%84%EB%A3%B8.png" alt="게임룸 테마" width="380" />
</p>

---

## Getting Started

1. 플러그인 폴더를 프로젝트의 `Plugins/` 아래에 둡니다.
2. UE 에디터에서 **Edit → Plugins**에서 본 플러그인을 활성화합니다.
3. **PCG**, **PCGEx** 플러그인을 함께 켜 두었는지 확인합니다.
4. 샘플 맵·DataAsset을 열어 Seed·그리드·에셋 교체 결과를 확인합니다.

> 노드별 의미·그래프 전체 흐름은 웹 본문과 중복되지 않도록 **Notion 가이드**를 참고하는 것을 권장합니다.
