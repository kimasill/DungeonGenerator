# 상단 배치 포인트 생성 로직 – 기술 문서(확정판)

## 목적
대형 오브젝트(테이블·캐비닛 등)의 상단면에 중형 오브젝트를 배치할 수 있도록, 각 대형 오브젝트의 로컬 좌표계 기준으로 정확히 정렬된 그리드 포인트를 생성한다.
- Copy Points 오프셋/정렬 문제를 방지
- 셀 개수 계산 일관화(+Y Forward, +X Right 규약 유지)

## 입력/출력
- 입력(Attributes / Params)
  - Points: 대형 오브젝트 포인트(위치·Yaw·Bounds 포함)
  - CellSize(Vector): 그리드 셀 간격(예: 150/150/150)
  - StackCellSize(Vector): 축별 원하는 셀 개수를 비율로 표현(예: 1×3×1 → 1.0, 3.0, 1.0)
  - TopClearance(float): 상판에서 띄우는 여유(충돌 방지)
  - PreferSnapCenter(bool, 선택): 홀수 셀 중앙 정렬 여부
- 출력
  - TopPoints: 상단 배치 그리드 포인트(대형 오브젝트 개수만큼 복제되어 각 상판 위에 정렬)

## 전체 플로우(요약)
1) 원점 기준 그리드 생성 →
2) Transform Points(Targets Local)로 각 대형 오브젝트로 복제·정렬 →
3) 상단 Z 오프셋 적용(상판 높이 + 클리어런스) →
4) Self Pruning 등으로 중복/외곽 포인트 정리 →
5) (옵션) 컨테이너 내부 전용 파이프라인

핵심: Copy Points로는 위치/회전 정렬이 되지 않는다. 반드시 Transform Points(Targets Local) 사용.

## 노드 레시피(권장 배선)
### A. 셀 개수 → Extents 변환(하프 익스텐트 규칙)
Create Points Grid는 Extents를 하프 익스텐트(half)로 해석한다. 원하는 셀 개수 N, 셀 간격 S일 때
- 안전식(짝/홀 공통): ExtentsAxis = ((N - 1) / 2) × S
- 그래프 구현 예:
  - CellCount = Round(Max(StackCellSizeAxis, 1.0))
  - HalfCount = Max(CellCount - 1, 0) × 0.5
  - ExtentsAxis = HalfCount × CellSizeAxis
- 예) X=1, Y=3, Z=1, CellSize=150 → Extents=(0, 150, 0)
- PCGEx에서 내부적으로 셀을 2배로 세는 상황을 방지하기 위해 반드시 위 공식을 사용

### B. 원점 기준 그리드 생성
- Create Points Grid
  - Grid Extents: (A)에서 계산된 Extents
  - Cell Size: 입력 CellSize
- 출력: 원점(0,0,0) 기준의 정렬된 그리드 포인트
- 디버그: PCGEx | Debug Bounds로 원점·의도 개수 확인

### C. 대형 오브젝트 상단으로 복제/정렬
- Transform Points(반드시 Targets Local)
  - In: (B)의 그리드 포인트
  - Targets Local: 대형 오브젝트 Points
  - 효과: 각 타깃의 위치/회전/스케일 반영하여 그리드 복제 및 로컬 정렬
- 보조축이 없으면: "PCG Write Direction Vector by Yaw"로 Right/Forward 벡터 기록(+X/+Y 규약)

### D. 상단 Z 오프셋(상판 높이 + 여유)
- 대형 오브젝트 상판 높이: UpperZ = BoundsMax.Z
- 현재 포인트 높이: TargetPos.Z
- 적용 오프셋: ZOffset = (UpperZ - TargetPos.Z) + TopClearance
- Transform Points의 Offset Min/Max의 Z에 ZOffset 적용
- 상판이 두껍거나 변동 높이가 있으면, 오브젝트 속성에서 상판 두께/오프셋을 추가 반영

### E. 정리 단계
- Self Pruning: 중복 포인트 제거
- (옵션) 방 경계 밖 제거: PCGEx | Filter : Inclusion(룸 바운즈)

## 컨테이너 내부 배치(옵션 분기)
상단이 아닌 내부에 포인트를 생성해야 하는 컨테이너(서랍·박스 등)용 보조 파이프라인:
1) (B) 그리드 생성은 동일(원점 기준)
2) Transform Points(Targets Local)로 컨테이너 포인트에 복제/정렬
3) Is Inside(Filter : Inclusion)으로 컨테이너 내부만 남김
4) 내부 충돌 방지: CellSize 축소(예: 0.5×) 또는 Bounds Modifier로 내부 여백 확보
5) 필요 시 상·하단 선택(Top/Bottom) 스위치로 Z 오프셋 차등 적용

## 속성 명명(권장)
- 입력: CellSize, StackCellSize, TopClearance
- 내부 계산: CellCountX/Y/Z, ExtentsX/Y/Z
- 출력: TopPoints
- 보조: RightVector, ForwardVector, BoundsMin/Max

## 흔한 실수 & 방지법
- Copy Points만 사용 → Transform Points(Targets Local)로 위치/회전/스케일 동기화. Copy Points는 속성 복사 용도.
- Extents를 전체 사이즈로 입력 → Create Points Grid는 하프 익스텐트. Extents = ((N-1)/2) × CellSize로 입력.
- Z 오프셋 미반영 → 상판 높이를 BoundsMax.Z 기준으로 계산 후 TopClearance 더하기.
- 축 규약 혼선 → Forward=+Y, Right=+X 규약 고정. 필요 시 Yaw→벡터 재기록.
