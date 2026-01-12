import 'package:flutter/material.dart';
import 'estate_calculator.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // --- 控制器与状态变量 ---
  final TextEditingController _principalCtrl = TextEditingController(text: "500000");
  final TextEditingController _ageCtrl = TextEditingController(text: "65");
  
  double _annualReturn = 6.0;    // 默认 6%
  double _marginalTax = 50.0;    // 默认 50%
  double _finalShock = -20.0;    // 默认 -20%

  EstateSimulationResult? _result;

  @override
  void initState() {
    super.initState();
    _calculate(); 
  }

  @override
  void dispose() {
    _principalCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    double principal = double.tryParse(_principalCtrl.text.replaceAll(',', '')) ?? 0;
    int age = int.tryParse(_ageCtrl.text) ?? 65;
    
    if (age > 80) age = 80;

    setState(() {
      _result = EstateCalculator.calculate(
        principal: principal,
        // debt: 0, // 已删除债务参数
        ageStart: age,
        ageDeath: 85,
        annualReturn: _annualReturn / 100,
        finalPeriodReturn: _finalShock / 100,
        marginalTaxRate: _marginalTax / 100,
      );
    });
  }

  String _formatCurrency(double val) {
    return "\$${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF00558C);
    const Color mintGreen = Color(0xFF7AB800);
    const Color textDark = Color(0xFF1A1D21);
    const Color textGrey = Color(0xFF64748B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("资产传承模拟器", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 顶部说明 ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(child: Text("适用账户: 非注册投资账户 (Non-Registered)\n资金需缴纳资本利得税与遗产认证费", style: TextStyle(fontSize: 12, color: Colors.orange, height: 1.3))),
                ],
              ),
            ),

            // --- 1. 输入区域 ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("设定您的投资背景", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  
                  // 第一行: 本金 & 年龄
                  Row(
                    children: [
                      Expanded(child: _buildTextField("投入金额 (Principal)", _principalCtrl)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTextField("投入时年龄 (建议65-70)", _ageCtrl, isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // 滑块: 预期回报率
                  _buildSliderRow("年平均回报率", _annualReturn, 0, 10, (v) => setState(() => _annualReturn = v), suffix: "%"),
                  
                  // 滑块: 边际税率
                  _buildSliderRow("边际税率 (Tax Rate)", _marginalTax, 30, 55, (v) => setState(() => _marginalTax = v), suffix: "%"),

                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // 最后5年回报率
                  const Text("假设: 85岁身故前 5年 的市场总表现", style: TextStyle(fontWeight: FontWeight.bold, color: primaryBlue)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("${_finalShock.toStringAsFixed(0)}%", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _finalShock < 0 ? Colors.red : Colors.green)),
                      Expanded(
                        child: Slider(
                          value: _finalShock,
                          min: -50,
                          max: 50,
                          divisions: 20,
                          activeColor: _finalShock < 0 ? Colors.red : Colors.green,
                          onChanged: (val) {
                            setState(() => _finalShock = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const Center(child: Text("拖动滑块模拟：大跌 (-50%) <---> 大涨 (+50%)", style: TextStyle(fontSize: 12, color: textGrey))),
                  
                  const SizedBox(height: 16),
                  
                  // --- MER 假设说明 ---
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("假设管理费 (MER):", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textGrey)),
                        Text("Mutual Fund 2.0%  vs  Seg Fund 3.0%", style: TextStyle(fontSize: 12, color: textGrey)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mintGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("开始计算对比", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- 2. 结果对比区域 ---
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("85岁身故时 资产传承价值对比", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                    const SizedBox(height: 4),
                    const Text("假设经过长期积累，并在最后5年经历上述市场波动", style: TextStyle(fontSize: 12, color: textGrey)),
                    const Divider(height: 30),
                    
                    // SF 行 (高亮)
                    _compareRow(
                      "保本基金 (Seg Fund)", 
                      _result!.sfNetEstate, 
                      primaryBlue, 
                      "已锁定保底 / 快速理赔 / 高ACB省税",
                      isHighlight: true
                    ),
                    const SizedBox(height: 16),
                    
                    // MF 行
                    _compareRow(
                      "互惠基金 (Mutual Fund)", 
                      _result!.mfNetEstate, 
                      textDark, 
                      "需扣除税费 / 等待 Probate 认证"
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 扣除项详情
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF7F9FC), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("互惠基金 (MF) 扣除明细:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textGrey)),
                          const SizedBox(height: 8),
                          _feeRow("账户总值", _result!.mfFinalValue, isPositive: true),
                          _feeRow("资本利得税 (Tax)", _result!.mfTaxPaid),
                          _feeRow("遗产/律师费 (Probate)", _result!.mfProbateFee),
                          const Divider(),
                          _feeRow("最终留给家人", _result!.mfNetEstate, isTotal: true),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                     Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF2FBF6), borderRadius: BorderRadius.circular(12)), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("保本基金 (SF) 优势分析:", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                          const SizedBox(height: 8),
                          _feeRow("理赔金额 (Payout)", _result!.sfPayoutAmount, isPositive: true),
                          _feeRow("遗产费用 (免 Probate)", 0.0),
                          _feeRow(
                            "资本利得税 (Tax)", 
                            _result!.sfTaxPaid, 
                            isTaxCredit: _result!.sfTaxPaid < 0 
                          ),
                          const Divider(),
                          _feeRow("最终留给家人", _result!.sfNetEstate, isTotal: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              
              // --- 3. 最终结论 ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _result!.diffAmount > 0 ? const Color(0xFFD4AF37) : Colors.grey, 
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Column(
                  children: [
                    Text(
                      _result!.diffAmount > 0 ? "通过保本基金，多留给家人" : "互惠基金表现略优 (仅多出)",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(_result!.diffAmount.abs()),
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                    if (_result!.diffAmount > 0)
                      const Text("(含税务节省、费用豁免及保本赔付)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const Center(child: Text("声明：此计算仅用于演示非注册账户的传承场景，不构成税务建议。", style: TextStyle(color: textGrey, fontSize: 10))),
            ],
          ],
        ),
      ),
    );
  }

  // --- UI 组件封装 ---
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            isDense: true,
          ),
          onChanged: (v) => _calculate(), 
        )
      ],
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, Function(double) onChanged, {String suffix = ""}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text("${value.toStringAsFixed(1)}$suffix", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00558C))),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: const Color(0xFF00558C),
          onChanged: (v) {
            onChanged(v);
            _calculate();
          },
        ),
      ],
    );
  }

  Widget _compareRow(String title, double val, Color color, String sub, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 15)),
                  if (isHighlight) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: Color(0xFFD4AF37), size: 16)
                  ]
                ],
              ),
              Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        Text(
          _formatCurrency(val),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color),
        ),
      ],
    );
  }

  Widget _feeRow(String label, double val, {bool isPositive = false, bool isTotal = false, bool isTaxCredit = false}) {
    Color valColor;
    String prefix = "-";
    
    if (isPositive || isTotal) {
      valColor = Colors.black;
      prefix = "";
    } else if (isTaxCredit) {
      valColor = Colors.green; 
      prefix = "+"; 
      val = val.abs(); 
    } else {
      valColor = Colors.red.shade300; 
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: const Color(0xFF64748B), fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(
            "$prefix${_formatCurrency(val)}", 
            style: TextStyle(fontSize: isTotal ? 16 : 12, color: valColor, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)
          ),
        ],
      ),
    );
  }
}