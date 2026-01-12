import 'dart:math';

/// 计算结果数据模型
class EstateSimulationResult {
  final double mfFinalValue;      // MF 最终市值
  final double sfFinalValue;      // SF 最终市值 (可能很低)
  final double sfPayoutAmount;    // SF 实际赔付额 (保底后)
  
  final double mfTaxPaid;         // MF 缴税
  final double sfTaxPaid;         // SF 缴税
  final double sfAdjustedAcb;     // SF 调整后的高成本基数
  
  final double mfProbateFee;      // MF 遗产认证费
  
  final double mfNetEstate;       // MF 最终到手
  final double sfNetEstate;       // SF 最终到手
  
  final double diffAmount;        // 差额 (SF - MF)
  final String winner;            // 赢家

  EstateSimulationResult({
    required this.mfFinalValue,
    required this.sfFinalValue,
    required this.sfPayoutAmount,
    required this.mfTaxPaid,
    required this.sfTaxPaid,
    required this.sfAdjustedAcb,
    required this.mfProbateFee,
    required this.mfNetEstate,
    required this.sfNetEstate,
    required this.diffAmount,
    required this.winner,
  });
}

class EstateCalculator {
  /// 核心计算方法
  static EstateSimulationResult calculate({
    required double principal,        // 投入本金
    required int ageStart,            // 开始年龄 (如 65)
    required int ageDeath,            // 身故年龄 (如 85)
    required double annualReturn,     // 年平均回报率 (0.06)
    required double finalPeriodReturn,// 最后阶段(5年)的总回报率 (-0.5 到 0.5)
    required double marginalTaxRate,  // 边际税率 (0.50)
  }) {
    
    // --- 1. 常量定义 ---
    const double probateFeeRate = 0.015; // 遗产费 1.5% (安省标准)
    const double legalFeeRate = 0.01;    // 律师/执行人费 1%
    const double totalEstateCostRate = probateFeeRate + legalFeeRate; 

    // --- 核心修改：明确定义的 MER ---
    const double merMf = 0.020;          // MF MER 2.0%
    const double merSeg = 0.030;         // Seg MER 3.0% (含保本成本)
    
    const double inclusionRate = 0.50;   // 资本利得计税比例 50%
    const double acbCreepRate = 0.005;   // Seg ACB 每年自动增长率 0.5%
    
    // 有效税率
    final double effectiveTaxRate = marginalTaxRate * inclusionRate;

    // --- 2. 时间轴拆分 ---
    final int lockInAge = ageDeath - 5; 
    
    int yearsAccum = lockInAge - ageStart; 
    if (yearsAccum < 0) yearsAccum = 0;
    
    const int yearsFinal = 5; 
    final int yearsTotal = yearsAccum + yearsFinal;

    // --- 3. 第一阶段: 积累期 (Start -> 锁定年龄) ---
    double netReturnMf = annualReturn - merMf;
    double netReturnSf = annualReturn - merSeg;

    // 加上 .toDouble() 修复类型错误
    double mfValueLocked = principal * pow((1 + netReturnMf), yearsAccum).toDouble();
    double sfValueLocked = principal * pow((1 + netReturnSf), yearsAccum).toDouble();
    
    // SF 锁定保底 (GDB)
    double sfGdbAmount = max(principal, sfValueLocked);

    // --- 4. 第二阶段: 最终震荡期 (最后5年) ---
    double mfFinalMv = mfValueLocked * (1 + finalPeriodReturn - (merMf * yearsFinal));
    double sfFinalMv = sfValueLocked * (1 + finalPeriodReturn - (merSeg * yearsFinal));

    // --- 5. 结算逻辑 (Settlement) ---

    // === Mutual Fund ===
    // 1. 资本利得税 (ACB = 本金)
    double mfCapitalGain = mfFinalMv - principal;
    double mfTax = 0;
    if (mfCapitalGain > 0) {
      mfTax = mfCapitalGain * effectiveTaxRate;
    }
    
    // 2. 遗产费用 (Probate + Legal)
    double mfEstateCost = mfFinalMv * totalEstateCostRate;
    
    // 3. 净值 (扣税、扣费) - 已删除债务扣除
    double mfNet = mfFinalMv - mfTax - mfEstateCost;
    if (mfNet < 0) mfNet = 0;

    // === Seg Fund ===
    // 1. 赔付额 (取 最大值: 市值 vs 保底)
    double sfPayout = max(sfFinalMv, sfGdbAmount);
    
    // 2. 高 ACB 计算
    double sfAdjustedAcb = principal * (1 + (acbCreepRate * yearsTotal));
    
    // 3. 税务计算
    double sfTaxableGain = sfFinalMv - sfAdjustedAcb;
    double sfTax = sfTaxableGain * effectiveTaxRate; 
    
    // 4. 净值 (赔付额 - 税)
    double sfNet = sfPayout - sfTax;

    // --- 6. 返回结果 ---
    return EstateSimulationResult(
      mfFinalValue: mfFinalMv,
      sfFinalValue: sfFinalMv,
      sfPayoutAmount: sfPayout,
      mfTaxPaid: mfTax,
      sfTaxPaid: sfTax,
      sfAdjustedAcb: sfAdjustedAcb,
      mfProbateFee: mfEstateCost,
      mfNetEstate: mfNet,
      sfNetEstate: sfNet,
      diffAmount: sfNet - mfNet,
      winner: sfNet > mfNet ? "Segregated Fund" : "Mutual Fund",
    );
  }
}