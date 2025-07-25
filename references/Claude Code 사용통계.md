# Claude Code 사용 통계 보는 방법  
ccusage라는 유틸리티를 사용합니다. 

## 사전 작업 
### bun 설치:
**1.Linux/Mac**
```bash
curl -fsSL https://bun.sh/install | bash
```
설정 적용: Mac은 ~/.zshrc, Linux는 ~/.bashrc에 추가 
```
export PATH="$HOME/.bun/bin:$PATH"
```

**2.Window**
```
powershell -c "irm bun.sh/install.ps1|iex"
```

## 일별/월별 사용량 보기  

```
bunx ccusage daily/monthly [--since YYYYMMDD] [--until YYYYMMDD]   
```
Cost는 만약에 Claude API를 사용했다면 예상되는 비용입니다. 
Claude Plan(Pro, Max)이 쓰는게 좋을 지 API를 쓰는게 좋을 지 판단할 수 있습니다.  
자주 사용한다면 Claude Plan이 보통 더 좋습니다.   
결과예시) 
┌────────────┬────────────────────┬───────────┬────────────┬───────────────┬──────────────┬───────────────┬─────────────┐
│ Date       │ Models             │     Input │     Output │  Cache Create │   Cache Read │  Total Tokens │  Cost (USD) │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-17 │ - opus-4           │        30 │        564 │        18,083 │       79,661 │        98,338 │       $0.50 │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-18 │ - opus-4           │        93 │      5,504 │        48,883 │      592,732 │       647,212 │       $2.22 │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-19 │ - opus-4           │     1,970 │     18,763 │       693,946 │    3,440,575 │     4,155,254 │      $11.67 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-20 │ - opus-4           │       278 │     12,473 │       489,926 │    8,802,587 │     9,305,264 │       $9.54 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-21 │ - opus-4           │     1,903 │     71,582 │     2,619,657 │   38,578,369 │    41,271,511 │      $32.23 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-22 │ - opus-4           │    12,653 │    187,476 │     4,107,587 │   42,906,986 │    47,214,702 │     $118.67 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-23 │ - opus-4           │    44,546 │    461,779 │     9,621,610 │  111,601,984 │   121,729,919 │     $293.80 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-24 │ - opus-4           │    10,910 │    215,913 │     5,978,451 │   67,865,559 │    74,070,833 │     $164.80 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-25 │ - sonnet-4         │     9,519 │    845,440 │    10,533,508 │  233,639,626 │   245,028,093 │     $122.30 │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ 2025-07-26 │ - opus-4           │     3,353 │    297,853 │     4,519,549 │  144,464,720 │   149,285,475 │     $240.53 │
│            │ - sonnet-4         │           │            │               │              │               │             │
├────────────┼────────────────────┼───────────┼────────────┼───────────────┼──────────────┼───────────────┼─────────────┤
│ Total      │                    │    85,255 │  2,117,347 │    38,631,200 │  651,972,799 │   692,806,601 │     $996.27 │
└────────────┴────────────────────┴───────────┴────────────┴───────────────┴──────────────┴───────────────┴─────────────┘

## 실시간 사용량 보기  

남은 세션 사용시간과 사용량 보기 
```
bunx ccusage blocks --live 
```
결과예시: 지금 세션 4시간 동안 사용할 수 있고 이 세션에서 1.5%사용했으며 세션이 끝날때까지 69.6% 사용이 예상됨 
예상 사용율을 보고 본인의 Claude 사용 플랜을 정할 수 있음 
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                        CLAUDE CODE - LIVE TOKEN USAGE MONITOR                                        │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                                      │
│ ⏱️ SESSION     [████░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]    5.1%                      │
│    Started: 오전 06:00:00  Elapsed: 15m  Remaining: 4h (오전 11:00:00)                                               │
│                                                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                                      │
│ 🔥 USAGE       [█░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░]    1.5% (1563.1k/102022.1k)  │
│    Tokens: 1,563,146 (Burn Rate: 243,814 token/min ⚡ MODERATE)  Limit: 102,022,107 tokens  Cost: $4.89              │
│                                                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                                      │
│ 📈 PROJECTION  [█████████████████████████████████████████████████░░░░░░░░░░░░░░░░░░░░░]   69.6% (70975.4k/102022.1k) │
│    Status: ✓ WITHIN LIMIT  Tokens: 70,975,437  Cost: $222.24                                                         │
│                                                                                                                      │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ ⚙️  Models: opus-4                                                                                                   │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                    ↻ Refreshing every 1s  •  Press Ctrl+C to stop                                    │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
