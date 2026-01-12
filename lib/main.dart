import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:gal/gal.dart'; 
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';

// 引入你新建的资产传承计算器页面
import 'calculator_page.dart'; 


// --- 1. 全局配置与配色 ---
class AppColors {
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFF7F9FC);
  
  static const Color primaryBlue = Color(0xFF00558C); 
  static const Color mintGreen = Color(0xFF7AB800); 
  static const Color luxuryGold = Color(0xFFD4AF37); 
  static const Color textDark = Color(0xFF1A1D21);
  static const Color textGrey = Color(0xFF64748B);
  
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFFB86B), Color(0xFFFF7A59)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient quizGradient = LinearGradient(
    colors: [Color(0xFF00558C), Color(0xFF0077BE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// --- 数据模型 ---
class QuestionOption {
  final String label;
  final String icon; 
  final Map<String, int> impact; 
  final String? triggerReason; 

  QuestionOption({
    required this.label, 
    required this.icon, 
    required this.impact,
    this.triggerReason,
  });
}

class Question {
  final String title;
  final List<QuestionOption> options;
  Question({required this.title, required this.options});
}

// 产品标签页数据模型
class ProductTabInfo {
  final String tabLabel; 
  final String cardTitle; 
  final String cardSubtitle; 
  final String description; 
  final List<String> features; 
  final bool isHighlight; 

  ProductTabInfo({
    required this.tabLabel,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.description,
    required this.features,
    this.isHighlight = false,
  });
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Insured618',
      theme: ThemeData(
        primarySwatch: Colors.blue, 
        fontFamily: GoogleFonts.notoSansSc().fontFamily,
      ),
      builder: (context, child) {
        if (kIsWeb && MediaQuery.of(context).size.width > 600) {
          return Container(
            color: const Color(0xFFF2F3F5), 
            alignment: Alignment.center,    
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16), 
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                child: child, 
              ),
            ),
          );
        }
        return child!;
      },
      home: const HomePage(), 
    );
  }
}

// --- 2. 首页 ---
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppColors.primaryBlue, size: 28),
            SizedBox(width: 8),
            Text(
              "Insured618",
              style: GoogleFonts.montserrat( 
                color: AppColors.primaryBlue, 
                fontSize: 22, 
                fontWeight: FontWeight.w900, 
                letterSpacing: -0.5, 
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent, color: AppColors.mintGreen, size: 28),
            tooltip: '预约咨询',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactPage(initialInterest: "首页预约")));
            },
          ),
        ],       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("你好 👋", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            SizedBox(height: 8),
            Text("今天想了解什么保险？", style: TextStyle(color: AppColors.textDark, fontSize: 24, fontWeight: FontWeight.w800)),
            
            SizedBox(height: 24), 
            
            // Smart Quiz Card
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const QuizPage())),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.warmGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Color(0xFFFF7A59).withOpacity(0.3), blurRadius: 15, offset: Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("不知道买什么？", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 4),
                          Text("花60秒做个智能测试，生成你的专属方案。", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),
            Text("浏览产品", style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),

            // 产品网格
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0, 
              children: [
                _buildCategoryCard(context, "ParLife", "分红终身寿险", Icons.account_balance, "ParLife"),
                _buildCategoryCard(context, "TermLife", "定期人寿保险", Icons.hourglass_top, "TermLife"),
                _buildCategoryCard(context, "CI", "重大疾病", Icons.monitor_heart_outlined, "CI"),
                _buildCategoryCard(context, "Disability", "伤残收入", Icons.accessible_forward, "Disability"),
                _buildCategoryCard(context, "Health", "健康牙医", Icons.medical_services_outlined, "Health"),
                _buildCategoryCard(context, "Wealth", "财富年金", Icons.trending_up, "Wealth"),
              ],
            ),

            // ... 上面是 GridView.count 的代码 ...
            
            const SizedBox(height: 32),
            
            // --- 新增：AI 顾问入口 (Gemini Link) ---
            GestureDetector(
              onTap: () async {
                // 你的 Gemini Gem 链接
                final Uri url = Uri.parse("https://gemini.google.com/gem/1lsYbGiOcI5IDB_0MV4n6K0zC6bFttr6Y?usp=sharing");
                try {
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    throw 'Could not launch $url';
                  }
                } catch (e) {
                  // 如果无法打开，可以在这里打印日志或提示
                  debugPrint("Error launching AI URL: $e");
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: BoxDecoration(
                  // 使用类似 Google Gemini 的蓝紫极光渐变色
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4E7CFE), Color(0xFF9F69FE)], 
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4E7CFE).withOpacity(0.4), 
                      blurRadius: 15, 
                      offset: const Offset(0, 8)
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // 左侧：AI 图标
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25), 
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1)
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    
                    // 中间：文字
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "和 AI 顾问聊聊...", 
                            style: TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 18,
                              letterSpacing: 0.5
                            )
                          ),
                          SizedBox(height: 6),
                          Text(
                            "基于 Gemini 的智能保险助手", 
                            style: TextStyle(color: Colors.white70, fontSize: 13)
                          ),
                        ],
                      ),
                    ),
                    
                    // 右侧：箭头
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: const Icon(Icons.arrow_outward, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            
            // 底部增加一点留白，防止到底部太挤
            const SizedBox(height: 50), 

          ], // <--- 这是 Column 的结束括号
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String subtitle, IconData icon, String productKey) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TabbedProductPage(productKey: productKey)));
      },
      child: Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primaryBlue, size: 28),
            ),
            SizedBox(height: 12),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
            Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}

// --- 3. 通用多标签产品详情页 (TabbedProductPage) ---
class TabbedProductPage extends StatefulWidget {
  final String productKey;
  const TabbedProductPage({super.key, required this.productKey});

  @override
  State<TabbedProductPage> createState() => _TabbedProductPageState();
}

class _TabbedProductPageState extends State<TabbedProductPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<ProductTabInfo> _tabsData;
  late String _pageTitle;
  late String _calcName;

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: _tabsData.length, vsync: this);
    
    // 🔥 关键修改：添加监听器，当 Tab 切换时刷新页面 (setState)，
    // 这样底部按钮文字才能从“年金税务”变成“资产传承”。
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  void _loadData() {
    switch (widget.productKey) {
      case 'Health':
        _pageTitle = "健康与牙医保险";
        _calcName = "医疗开销"; 
        _tabsData = [
          ProductTabInfo(
            tabLabel: "个人险\n(Personal)",
            cardTitle: "Personal Health",
            cardSubtitle: "适合自雇/无福利者",
            description: "灵活性高，需回答健康问卷。包含 Basic, Extenda, Omni 三档计划。",
            features: ["基础处方药 & 牙科", "视力护理 (Extenda/Omni)", "按摩/理疗/针灸", "24/7 远程医疗支持"],
            isHighlight: true
          ),
          ProductTabInfo(
            tabLabel: "替代险\n(Replacement)",
            cardTitle: "Replacement Health",
            cardSubtitle: "离职/退休 90天内",
            description: "无需体检！保证承保！覆盖既往症。适合刚失去团体保险的人群。",
            features: ["保证承保 (无既往症除外)", "延续原有保障", "包含15天境外旅游险 (Choice/Premier)", "心理健康支持"],
          ),
        ];
        break;

      case 'TermLife': 
        _pageTitle = "定期人寿保险";
        _calcName = "保额缺口";
        _tabsData = [
          ProductTabInfo(
            tabLabel: "灵活型\n(Evolve)",
            cardTitle: "Evolve",
            cardSubtitle: "功能最全 · 可升级",
            description: "适合需要灵活性、未来可能调整保单的家庭。",
            features: ["期限 5-40 年可选", "可转换为终身寿险 (75岁前)", "可续保至 85 岁", "可增加子女/意外附加险"],
            isHighlight: true
          ),
          ProductTabInfo(
            tabLabel: "实惠型\n(Essential)",
            cardTitle: "Essential",
            cardSubtitle: "价格最低 · 纯保障",
            description: "适合预算有限、只需短期简单保障的人群。",
            features: ["期限 5-20 年可选", "保费极具竞争力", "不可转换为终身险", "不可续保"],
          ),
        ];
        break;

      case 'ParLife': 
        _pageTitle = "分红终身寿险";
        _calcName = "遗产传承";
        _tabsData = [
          ProductTabInfo(
            tabLabel: "遗产型\n(Estate)",
            cardTitle: "Protector",
            cardSubtitle: "长期复利 · 传世之宝",
            description: "以较低保费获得较高终身保障，红利长期滚存，适合留给子孙。",
            features: ["终身保障 + 分红增长", "免税复利", "规避遗嘱认证费 (Probate)", "稳健资产配置"],
            isHighlight: true
          ),
          ProductTabInfo(
            tabLabel: "资产型\n(Accumulator)",
            cardTitle: "Accumulator",
            cardSubtitle: "高现金流 · 企业主首选",
            description: "早期现金价值更高，适合需要资产流动性的企业主。",
            features: ["早期现金价值高", "资产负债表优化", "退休收入补充", "企业资本红利账户 (CDA)"],
          ),
          ProductTabInfo(
            tabLabel: "8年快付\n(Accelerator)",
            cardTitle: "Accelerator",
            cardSubtitle: "8年付清 · 无债一身轻",
            description: "只需缴付8年保费，即可享受终身保障与分红。",
            features: ["8年保证付清", "无长期供款压力", "适合送给孩子的礼物", "快速建立资产"],
          ),
        ];
        break;

      case 'CI': 
        _pageTitle = "重大疾病保险";
        _calcName = "康复基金";
        _tabsData = [
          ProductTabInfo(
            tabLabel: "全面保障\n(Full)",
            cardTitle: "Comprehensive",
            cardSubtitle: "覆盖最广 · 包含早期",
            description: "确诊26种重疾全额赔付，8种早期疾病预赔。",
            features: ["26种全额理赔 (癌症/心脏病等)", "8种早期预赔 (不减总额)", "全球顶尖医疗意见服务", "长期护理转换权 (LTC)"],
            isHighlight: true
          ),
          ProductTabInfo(
            tabLabel: "返本计划\n(MoneyBack)",
            cardTitle: "没病还钱 (ROPD)",
            cardSubtitle: "进可攻 · 退可守",
            description: "如果您一直健康未理赔，可选择退还 100% 保费。",
            features: ["100% 保费退还 (15年后/65岁)", "相当于利息买保障", "本金安全", "包含所有全面保障功能"],
          ),
        ];
        break;
      
      case 'Wealth': 
        _pageTitle = "财富与年金";
        // 注意：这里的名称虽然叫“资产传承”，但实际显示的按钮文字会根据 Tab 动态变化
        _calcName = "资产传承"; 
        _tabsData = [
          ProductTabInfo(
            tabLabel: "年金\n(Annuity)",
            cardTitle: "终身年金 (Payout Annuity)",
            cardSubtitle: "保证收入 · 活多久领多久",
            description: "将积蓄转化为源源不断的现金流，消除市场风险。就像自己给自己发养老金，无需担心钱花光。",
            features: ["终身保证收入 (Lifetime Income)", "无视股市波动", "税务优惠 (仅利息缴税)", "适合支付刚性支出"],
          ),
          ProductTabInfo(
            tabLabel: "保本基金\n(Seg Funds)",
            cardTitle: "保本基金 (Segregated Funds)",
            cardSubtitle: "自带保险特性的“装甲运钞车”", 
            description: "互惠基金(Mutual Funds)像普通轿车，而保本基金是配备“防弹玻璃”的装甲车。本质是保险合同，提供互惠基金没有的安全网：锁定收益、资产保全及税务便利。", 
            features: [
              "本金与身故保证 (75%/100% + Reset 锁定收益)",
              "遗产规划神器 (绕过 Probate + 快速私密理赔)",
              "债权人保护 (Creditor Protection) - 企业主必备",
              "税务优势 (亏损可分配抵税 + 自动追踪 ACB)" 
            ],
            isHighlight: true
          ),
        ];
        break;

      default: 
        _pageTitle = "伤残收入保险";
        _calcName = "收入盾牌";
        _tabsData = [
          ProductTabInfo(
            tabLabel: "专业人士",
            cardTitle: "Pro Disability",
            cardSubtitle: "定义宽松",
            description: "适合医生、律师、IT专业人士，本职工作无法从事即赔付。",
            features: ["Own Occupation 定义", "部分残疾赔付", "生活成本调整 (COLA)", "未来保额增加权"],
            isHighlight: true
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _pageTitle,
          style: GoogleFonts.notoSansSc( 
            color: Colors.black87,
            fontSize: 20, 
            fontWeight: FontWeight.w600, 
            letterSpacing: 1.0, 
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryBlue,
          indicatorWeight: 3,
          labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabsData.map((t) => Tab(text: t.tabLabel)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabsData.map((data) => _buildTabContent(data)).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5), 
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Builder(
                  builder: (context) {
                    bool isHealthInsurance = widget.productKey == 'Health';
                    
                    // --- 动态判断当前 Tab ---
                    bool isAnnuityTab = widget.productKey == 'Wealth' && _tabController.index == 0;
                    bool isSegFundTab = widget.productKey == 'Wealth' && _tabController.index == 1;

                    String btnLabel;
                    if (isHealthInsurance) {
                      btnLabel = "帮我选计划 (Smart Finder)";
                    } else if (isSegFundTab) {
                      btnLabel = "打开资产传承模拟器"; // 新功能
                    } else {
                      btnLabel = "打开$_calcName计算器"; // 旧功能
                    }
                    
                    return OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: isHealthInsurance ? Colors.purple : AppColors.primaryBlue), 
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      
                      icon: Icon(
                        isHealthInsurance ? Icons.recommend_outlined : Icons.calculate_outlined, 
                        color: isHealthInsurance ? Colors.purple : AppColors.primaryBlue
                      ),
                      
                      onPressed: () {
                        if (isHealthInsurance) {
                          // 1. 健康险 -> Smart Finder
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => HealthPlanSelector(title: _pageTitle))
                          );
                        } else if (isSegFundTab) {
                          // 2. 保本基金 (Wealth Tab 1) -> 【新】资产传承计算器
                          // 修复: 移除了 const，直接实例化 CalculatorPage
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => CalculatorPage()) 
                          );
                        } else {
                          // 3. 其他情况 (含年金 Tab 0) -> 【旧】通用计算器
                          // 修复: 这里的类名已重命名为 GeneralCalculatorPage
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => GeneralCalculatorPage(productKey: widget.productKey, title: _pageTitle))
                          );
                        }
                      },
                      
                      label: Text(
                        btnLabel,
                        style: TextStyle(
                          color: isHealthInsurance ? Colors.purple : AppColors.primaryBlue, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 16
                        )
                      ),
                    );
                  }
                ),
                
                const SizedBox(height: 16), 
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    minimumSize: const Size(double.infinity, 54), 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(initialInterest: _pageTitle)));
                  },
                  child: const Text("联系顾问获取方案", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(ProductTabInfo data) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: data.isHighlight ? AppColors.luxuryGold : Colors.grey.shade200, width: data.isHighlight ? 2 : 1),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: Offset(0, 5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(data.cardTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark))),
                    if (data.isHighlight)
                      Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.luxuryGold, borderRadius: BorderRadius.circular(4)), child: Text("推荐", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))
                  ],
                ),
                SizedBox(height: 4),
                Text(data.cardSubtitle, style: TextStyle(fontSize: 12, color: AppColors.mintGreen, fontWeight: FontWeight.bold)),
                Divider(height: 24),
                Text(data.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                SizedBox(height: 20),
                ...data.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Expanded(child: Text(f, style: TextStyle(fontSize: 14, color: AppColors.textDark))),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (widget.productKey == 'CI')
             _buildInfoBox(Icons.medical_services, "全球顶尖医疗意见", "包含由 Dialogue 提供的第二诊疗意见服务，帮您复核诊断。"),
          if (widget.productKey == 'ParLife')
             _buildInfoBox(Icons.trending_up, "分红历史", "自1877年以来，保险公司每年都向保单持有人派发红利。"),
          if (widget.productKey == 'TermLife')
             _buildInfoBox(Icons.swap_horiz, "可转换权", "75岁前可免体检转换为终身分红保险，锁定身体健康时的费率等级。"),
          if (widget.productKey == 'Health')
             _buildInfoBox(Icons.phone_in_talk, "24/7 远程医疗", "包含加拿大持牌医生电话视频问诊，可开具电子处方。"),
        ],
      ),
    );
  }

  Widget _buildInfoBox(IconData icon, String title, String desc) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textGrey, size: 24),
          SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(desc, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          ]))
        ],
      ),
    );
  }
}

// --- 4. 联系方式名片页 (含隐私政策 & 免责声明) ---
class ContactPage extends StatelessWidget {
  final String initialInterest;
  const ContactPage({super.key, required this.initialInterest});

  final String _privacyUrl = "https://www.freeprivacypolicy.com/live/2885e378-eeb1-4b65-b6f5-8b513c976273";

  Future<void> _performAction(BuildContext context, String type, String value) async {
    if (type == '复制') {
      Clipboard.setData(ClipboardData(text: value));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("已复制 $value 到剪贴板"),
        backgroundColor: AppColors.mintGreen,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    Uri? launchUri;
    try {
      if (type == '邮件') {
        launchUri = Uri(scheme: 'mailto', path: value);
      } else if (type == '网站') {
         launchUri = Uri.parse(value);
      }

      if (launchUri != null) {
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("无法打开应用"),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse(_privacyUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showDisclaimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.gavel, color: Colors.orange),
              SizedBox(width: 8),
              Text("免责声明 / Disclaimer", style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "中文声明：",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "本应用程序（Insured618）仅为保险规划辅助工具。App 中展示的所有数字、计算结果及产品信息仅供演示和参考，不构成任何保险合同、法律建议或承保要约。\n\n实际保费、现金价值及保障内容最终以保险公司的正式建议书（Illustration）及核保结果为准。投资回报率（如分红率）基于历史数据或假设，并非未来收益的保证。",
                  style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                ),
                Divider(height: 24, thickness: 1),
                Text(
                  "English Disclaimer:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "This application (Insured618) is intended for illustrative and educational purposes only. All figures, calculations, and product information presented do not constitute an insurance contract, legal advice, or an offer of coverage.\n\nActual premiums, cash values, and coverage are subject to the official policy illustration and underwriting approval by the insurance company. Investment returns (e.g., dividend scales) are based on historical data or assumptions and are not guaranteed.",
                  style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("我已知晓 (I Understand)", style: TextStyle(color: AppColors.primaryBlue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('提示：请直接 "右键" 或 "长按" 图片进行保存'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      return; 
    }

    try {
      final ByteData bytes = await rootBundle.load('assets/IMG_1013.jpeg');
      final Uint8List list = bytes.buffer.asUint8List();
      await Gal.putImageBytes(list, name: "Insured618_QR");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 二维码已成功保存到相册！'), backgroundColor: AppColors.mintGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('保存出错，请稍后重试'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("联系顾问"),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(child: Text("您对 \"$initialInterest\" 很感兴趣？\n请直接联系顾问获取免费方案。", style: TextStyle(color: Colors.orange.shade800, fontSize: 13, height: 1.4))),
                ],
              ),
            ),
            const SizedBox(height: 24),

            GestureDetector(
              onLongPress: () => _saveImage(context),
              onTap: () {
                if (kIsWeb) _saveImage(context); 
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/weixin.jpg', 
                    width: 220,      
                    height: 280,     
                    fit: BoxFit.contain, 
                    errorBuilder: (context, error, stackTrace) {
                      return Container(width: 220, height: 220, color: Colors.grey.shade200, child: const Icon(Icons.qr_code, size: 80, color: Colors.grey));
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text("长按上方二维码保存图片，在微信中识别", style: TextStyle(color: Colors.grey, fontSize: 12)),
            
            const SizedBox(height: 32),

            _buildContactCard(context, "微信 (WeChat)", "Insures618", Icons.chat, "复制", isHighlight: true),
            const SizedBox(height: 16),
            _buildContactCard(context, "电子邮箱", "insured618@gmail.com", Icons.email, "邮件"),

            const SizedBox(height: 40),
            Text("工作时间: 周一至周五 9:00 - 18:00 (EST)", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            
            const SizedBox(height: 30),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _openPrivacyPolicy,
                    child: const Text("隐私政策\nPrivacy Policy", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                  Container(height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                  TextButton(
                    onPressed: () => _showDisclaimerDialog(context),
                    child: const Text("免责声明\nDisclaimer", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactCard(BuildContext context, String title, String value, IconData icon, String actionText, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFF2FBF6) : Colors.white, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isHighlight ? AppColors.mintGreen.withOpacity(0.3) : Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isHighlight ? AppColors.mintGreen : AppColors.surface, shape: BoxShape.circle),
            child: Icon(icon, color: isHighlight ? Colors.white : AppColors.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _performAction(context, actionText, value),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionText == '复制' ? AppColors.surface : AppColors.primaryBlue,
              foregroundColor: actionText == '复制' ? AppColors.textDark : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text(actionText),
          )
        ],
      ),
    );
  }
}

// =======================
// 5. 通用计算器页面 (Renamed to GeneralCalculatorPage)
// =======================

// --- 新功能：健康险智能选品助手 (Smart Finder - 重构版) ---
class HealthPlanSelector extends StatefulWidget {
  final String title;
  const HealthPlanSelector({super.key, required this.title});

  @override
  State<HealthPlanSelector> createState() => _HealthPlanSelectorState();
}

class _HealthPlanSelectorState extends State<HealthPlanSelector> {
  // 1. 模式选择: true = 个人险 (Personal), false = 替代险 (Replacement)
  // 默认根据标题判断，如果是 Replacement 就切过去
  late bool _isPersonal;
  
  // 2. 覆盖层级 (0: Default/Basic/Essential, 1: Medium/Extenda/Choice, 2: High/Omni/Premier)
  double _coverageLevel = 0;

  // 3. 个人险专属 - 附加选项 (Add-ons)
  bool _addDrugs = false;
  bool _addDental = false;
  bool _addTravel = false;

  @override
  void initState() {
    super.initState();
    // 自动检测初始 tab
    _isPersonal = !widget.title.contains("Replacement");
  }

  // --- 核心推荐逻辑 ---
  Map<String, dynamic> _getRecommendation() {
    if (_isPersonal) {
      // === 个人险 (Personal Health) ===
      String planName = "";
      String desc = "";
      Color color = Colors.green;
      
      // 根据层级判断基础计划
      if (_coverageLevel == 0) {
        planName = "Basic Plan";
        desc = "✅ 基础保障\n• 视力护理: 无\n• 按摩/理疗: 70% 报销";
        color = Colors.green;
      } else if (_coverageLevel == 1) {
        planName = "Extenda Plan";
        desc = "⚡️ 进阶保障\n• 视力护理: 80% 报销\n• 按摩/理疗: 80% 报销";
        color = Colors.blue;
      } else {
        planName = "Omni Plan";
        desc = "💎 全面保障\n• 视力护理: 90% 报销\n• 按摩/理疗: 90% 报销";
        color = Colors.purple;
      }

      // 拼接附加险
      List<String> addons = [];
      if (_addDrugs) addons.add("处方药");
      if (_addDental) addons.add("牙科");
      if (_addTravel) addons.add("旅行险");
      
      String finalTitle = planName;
      if (addons.isNotEmpty) {
        finalTitle += " + ${addons.join('/')}";
      }

      return {
        "plan": finalTitle,
        "desc": desc,
        "color": color,
        "icon": _coverageLevel == 2 ? Icons.diamond_outlined : Icons.shield_outlined,
      };

    } else {
      // === 替代险 (Replacement Health) ===
      // 逻辑: Essential -> Choice -> Premier
      if (_coverageLevel == 0) {
        return {
          "plan": "Essential Plan",
          "desc": "🛡️ 入门版 (无处方药/旅行)\n• 处方药: 无\n• 旅行险: 无\n• 视力: \$100\n• 牙科: 80% (上限\$1000)\n• 按摩/理疗: 50%",
          "color": Colors.orange,
          "icon": Icons.health_and_safety_outlined,
        };
      } else if (_coverageLevel == 1) {
        return {
          "plan": "Choice Plan",
          "desc": "⚖️ 平衡版\n• 处方药: 80% (上限\$1250)\n• 旅行险: 7天/次\n• 视力: \$150\n• 牙科: 80% (上限\$1250)\n• 按摩/理疗: 80%",
          "color": Colors.teal,
          "icon": Icons.balance_outlined,
        };
      } else {
        return {
          "plan": "Premier Plan",
          "desc": "👑 尊享版\n• 处方药: 80% (上限\$2500)\n• 旅行险: 15天/次\n• 视力: \$300\n• 牙科: 80% (上限\$1500)\n• 按摩/理疗: 100%",
          "color": Colors.indigo,
          "icon": Icons.workspace_premium_outlined,
        };
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = _getRecommendation();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("智能选品 Smart Finder", style: TextStyle(color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 顶部切换开关 (Personal vs Replacement)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  _buildTabButton("个人险 (Personal)", true),
                  _buildTabButton("替代险 (Replacement)", false),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. 滑动选择层级 (Level Slider)
            Text(
              _isPersonal ? "选择保障强度 (Coverage Level)" : "选择计划档次 (Plan Tier)", 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Slider(
                    value: _coverageLevel,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: _getLevelLabel(_coverageLevel.toInt()),
                    activeColor: AppColors.primaryBlue,
                    onChanged: (val) => setState(() => _coverageLevel = val),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_isPersonal ? "Basic" : "Essential", style: TextStyle(color: _coverageLevel==0 ? AppColors.primaryBlue : Colors.grey, fontWeight: FontWeight.bold)),
                        Text(_isPersonal ? "Extenda" : "Choice", style: TextStyle(color: _coverageLevel==1 ? AppColors.primaryBlue : Colors.grey, fontWeight: FontWeight.bold)),
                        Text(_isPersonal ? "Omni" : "Premier", style: TextStyle(color: _coverageLevel==2 ? AppColors.primaryBlue : Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. 个人险专属：附加选项 (Checkboxes)
            if (_isPersonal) ...[
              const SizedBox(height: 24),
              const Text("添加额外保障 (Add-ons)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text("处方药 (Drugs)", style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _addDrugs,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _addDrugs = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text("牙科 (Dental)", style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _addDental,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _addDental = v),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text("旅行险 (Travel)", style: TextStyle(fontWeight: FontWeight.w600)),
                      value: _addTravel,
                      activeColor: Colors.green,
                      onChanged: (v) => setState(() => _addTravel = v),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 30),
            
            // 4. 结果展示卡片
            const Text("为您推荐 (Recommended):", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: recommendation['color'], width: 2),
                boxShadow: [
                  BoxShadow(color: recommendation['color'].withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Icon(recommendation['icon'], size: 50, color: recommendation['color']),
                  const SizedBox(height: 16),
                  Text(
                    recommendation['plan'],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: recommendation['color']),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      recommendation['desc'],
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(initialInterest: "咨询 ${recommendation['plan']}")));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: recommendation['color'],
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text("获取该计划报价", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isPersonalTab) {
    bool isActive = _isPersonal == isPersonalTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
           _isPersonal = isPersonalTab;
           _coverageLevel = 0; // 切换 Tab 时重置滑块
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.black : Colors.grey,
              fontSize: 13
            ),
          ),
        ),
      ),
    );
  }

  String _getLevelLabel(int level) {
    if (_isPersonal) {
      return ["Basic", "Extenda", "Omni"][level];
    } else {
      return ["Essential", "Choice", "Premier"][level];
    }
  }
}

// 🔥🔥 关键重命名：将原来的 CalculatorPage 改为 GeneralCalculatorPage
class GeneralCalculatorPage extends StatefulWidget {
  final String productKey;
  final String title;
  const GeneralCalculatorPage({super.key, required this.productKey, required this.title});

  @override
  State<GeneralCalculatorPage> createState() => _GeneralCalculatorPageState();
}

class _GeneralCalculatorPageState extends State<GeneralCalculatorPage> {
  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  final TextEditingController _c3 = TextEditingController();
  final TextEditingController _c4 = TextEditingController();
  final TextEditingController _c5 = TextEditingController();
  final TextEditingController _c6 = TextEditingController();
  final TextEditingController _c7 = TextEditingController();

  int _paymentYears = 20; 
  String _selectedGender = 'Male'; 
  String resultText = "请输入数据开始计算";
  String resultValue = "\$0";
  String? secondaryResult; 
  bool _showComparison = false;
  Map<String, double> _wealthData = {};

  @override
  void dispose() {
    _c1.dispose(); _c2.dispose(); _c3.dispose(); _c4.dispose(); 
    _c5.dispose(); _c6.dispose(); _c7.dispose();
    super.dispose();
  }

  void _calculate() {
    double v1 = double.tryParse(_c1.text) ?? 0;
    double v2 = double.tryParse(_c2.text) ?? 0;
    double v3 = double.tryParse(_c3.text) ?? 0;
    double v4 = double.tryParse(_c4.text) ?? 0;
    double v5 = double.tryParse(_c5.text) ?? 0;
    double v6 = double.tryParse(_c6.text) ?? 0;
    double v7 = double.tryParse(_c7.text) ?? 0;
    double finalVal = 0;
    String? subText;

    setState(() {
      _showComparison = false;

      switch (widget.productKey) {
        case 'TermLife':
          finalVal = (v1 + v2 + v3 + (v4 * 10)) - v5;
          if (finalVal < 0) finalVal = 0;
          resultText = "建议 Term Life 保额";
          resultValue = _formatCurrency(finalVal);
          break;
          
        case 'ParLife': 
          double currentAge = v1;
          double annualPremium = v2;
          double taxRate = _c3.text.isEmpty ? 0.50 : v3 / 100;
          double assumedReturn = _c4.text.isEmpty ? 0.0625 : v4 / 100;
          double targetAge = 85; 
          int yearsToPay = _paymentYears; 
          int totalGrowthYears = (targetAge - currentAge).toInt();
          if (totalGrowthYears < 0) totalGrowthYears = 0;
          double insuranceFV = 0;
          if (assumedReturn > 0) {
            double fvAtPaymentEnd = annualPremium * (pow(1 + assumedReturn, yearsToPay) - 1) / assumedReturn * (1 + assumedReturn);
            int remainingYears = totalGrowthYears - yearsToPay;
            if (remainingYears < 0) remainingYears = 0; 
            insuranceFV = fvAtPaymentEnd * pow(1 + assumedReturn, remainingYears);
          } else {
            insuranceFV = annualPremium * yearsToPay;
          }
          double netInsurance = insuranceFV;
          double investmentFV = insuranceFV;
          double totalCostBasis = annualPremium * yearsToPay;
          double capitalGain = investmentFV - totalCostBasis;
          if (capitalGain < 0) capitalGain = 0;
          double taxableGain = capitalGain * 0.50;
          double taxOnGain = taxableGain * taxRate;
          double afterTaxValue = investmentFV - taxOnGain;
          double probateFee = 0;
          if (afterTaxValue > 50000) {
            probateFee = (afterTaxValue - 50000) * 0.015;
          }
          double legalFee = afterTaxValue * 0.02;
          double netInvestment = afterTaxValue - probateFee - legalFee;

          _showComparison = true;
          _wealthData = {
            'netInsurance': netInsurance,
            'grossInv': investmentFV,
            'taxOnGain': taxOnGain,
            'probate': probateFee,
            'legal': legalFee,
            'netInvestment': netInvestment,
          };
          resultText = "计算完成"; 
          resultValue = ""; 
          break;

        case 'Wealth': 
          double age = v1;
          double premium = v2;
          double taxRate = _c3.text.isEmpty ? 0.50 : v3 / 100;
          double interestRate = _c4.text.isEmpty ? 0.03 : v4 / 100;
          int lifeExpectancy = (_selectedGender == 'Male') ? 82 : 85;
          double duration = (lifeExpectancy - age).toDouble();
          if (duration <= 0) duration = 1; 
          double annuityPMT = 0;
          if (interestRate > 0) {
            annuityPMT = (premium * interestRate) / (1 - pow(1 + interestRate, -duration));
          } else {
            annuityPMT = premium / duration;
          }
          double annuityCapitalPortion = premium / duration;
          double annuityTaxablePortion = annuityPMT - annuityCapitalPortion;
          if (annuityTaxablePortion < 0) annuityTaxablePortion = 0;
          double annuityTax = annuityTaxablePortion * taxRate;
          double annuityNet = annuityPMT - annuityTax;
          double gicInterest = premium * interestRate; 
          double gicTax = gicInterest * taxRate;
          double gicNet = annuityPMT - gicTax;
          _showComparison = true;
          _wealthData = {
            'gross': annuityPMT,
            'annuityTax': annuityTax,
            'annuityNet': annuityNet,
            'gicTax': gicTax,
            'gicNet': gicNet,
            'years': duration
          };
          resultText = "计算完成"; 
          resultValue = "";
          break;

        case 'CI': 
          double years = v1;
          double annualIncome = v2;
          double monthlyExpenses = v3 + v4 + v5 + v6;
          double extraMedical = v7;
          double optionA = annualIncome * years;
          double optionB = (monthlyExpenses * 12 * years) + extraMedical;
          finalVal = max(optionA, optionB);
          resultText = "建议重疾保额"; 
          resultValue = _formatCurrency(finalVal);
          break;

        case 'Disability':
          double incomeCap = v1 * 0.60;
          double expenses = v2 + v3 + v4 + v5;
          finalVal = (incomeCap < expenses) ? incomeCap : expenses;
          resultText = "建议月赔付额"; 
          resultValue = _formatCurrency(finalVal);
          break;

        case 'Health':
          finalVal = v1 + v2 + v3;
          resultText = "年度潜在自费总额";
          resultValue = _formatCurrency(finalVal);
          break;
      }
      secondaryResult = subText;
    });
  }

  String _formatCurrency(double val) {
    return "\$${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title.split('(')[0] + "计算器"), backgroundColor: Colors.white, elevation: 0, leading: IconButton(icon: Icon(Icons.close, color: AppColors.textDark), onPressed: () => Navigator.pop(context))),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            if (_showComparison)
              if (widget.productKey == 'ParLife') 
                _buildParLifeComparison()
              else if (widget.productKey == 'Wealth')
                _buildWealthComparison()
              else
                Container()
            else
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Text(resultText, style: TextStyle(color: Colors.white70, fontSize: 14)),
                    SizedBox(height: 8),
                    Text(resultValue, style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    if (widget.productKey == 'Disability') 
                      Padding(padding: const EdgeInsets.only(top: 8.0), child: Text("(取收入60%与总开销之较小值)", style: TextStyle(color: Colors.white60, fontSize: 10))),
                    if (widget.productKey == 'CI') 
                      Padding(padding: const EdgeInsets.only(top: 8.0), child: Text("(取收入替代与开销覆盖之较大值)", style: TextStyle(color: Colors.white60, fontSize: 10)))
                  ],
                ),
              ),
            
            SizedBox(height: 24),
            _buildInputs(),
            SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.mintGreen, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _calculate, child: Text("开始计算", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
          ],
        ),
      ),
    );
  }

  Widget _buildParLifeComparison() {
    double netIns = _wealthData['netInsurance'] ?? 0;
    double netInv = _wealthData['netInvestment'] ?? 0;
    double tax = _wealthData['taxOnGain'] ?? 0;
    double probate = _wealthData['probate'] ?? 0;
    double legal = _wealthData['legal'] ?? 0;
    double diff = netIns - netInv;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("85岁时资产传承价值对比", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              SizedBox(height: 4),
              Text("假设相同回报率，计算税后净值", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Divider(height: 30),
              _compareRow("分红保险 (Par Life)", netIns, AppColors.primaryBlue, "免税 Benefit"),
              SizedBox(height: 16),
              _compareRow("普通投资 (Investment)", netInv, AppColors.textDark, "扣除税/Probate/律师费"),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _feeRow("资本利得税 (Tax)", tax),
                    _feeRow("遗产认证费 (Probate)", probate),
                    _feeRow("执行/律师费 (Legal)", legal),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.luxuryGold, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text("通过保险传承，多留给家人", style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 4),
              Text("${_formatCurrency(diff)}", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildWealthComparison() {
    double gross = _wealthData['gross'] ?? 0;
    double annNet = _wealthData['annuityNet'] ?? 0;
    double gicNet = _wealthData['gicNet'] ?? 0;
    double taxSaved = annNet - gicNet;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("年金 vs GIC 税务对比 (每年)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
              SizedBox(height: 4),
              Text("假设两者产生相同的税前现金流: ${_formatCurrency(gross)}", style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
              Divider(height: 30),
              _compareRow("年金 (Annuity)", annNet, AppColors.primaryBlue, "仅利息部分缴税"),
              SizedBox(height: 16),
              _compareRow("GIC / 债券", gicNet, AppColors.textDark, "利息全额缴税"),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.mintGreen, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Text("使用年金，您每年多得", style: TextStyle(color: Colors.white, fontSize: 14)),
              SizedBox(height: 4),
              Text("${_formatCurrency(taxSaved)}", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              Text("免税净收入", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
            ],
          ),
        )
      ],
    );
  }

  Widget _compareRow(String title, double val, Color color, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          Text(sub, style: TextStyle(fontSize: 10, color: AppColors.textGrey)),
        ]),
        Text(_formatCurrency(val), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
      ],
    );
  }

  Widget _feeRow(String label, double val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
          Text("-${_formatCurrency(val)}", style: TextStyle(fontSize: 12, color: Colors.red.shade300)),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    switch (widget.productKey) {
      case 'TermLife': 
        return Column(children: [
          _inputField("1. 房贷余额", _c1),
          _inputField("2. 其他债务 (车贷/卡债)", _c2),
          _inputField("3. 子女教育预留金", _c3),
          _inputField("4. 您的年收入 (用于计算10年替代)", _c4),
          _inputField("5. 现有存款/保险 (减项)", _c5),
        ]);
      
      case 'ParLife': 
        return Column(children: [
          _inputField("1. 目前年龄 (Current Age)", _c1, hint: "例如: 40"),
          _inputField("2. 每年保费 (Annual Premium)", _c2, hint: "例如: 20000"),
          _inputField("3. 边际税率 (%)", _c3, hint: "默认: 50"),
          _inputField("4. 投资回报率 (%)", _c4, hint: "默认: 6.25"),
        ]);

      case 'Wealth': 
        return Column(children: [
          _inputField("1. 计划领取年龄", _c1, hint: "65"),
          _inputField("2. 投入总金额", _c2, hint: "例如: 500000"),
          _inputField("3. 边际税率 (%)", _c3, hint: "默认: 50"),
          _inputField("4. 假设利息 (%)", _c4, hint: "例如: 3"),
        ]);

      case 'CI':
        return Column(children: [
          _inputField("预估康复休息年数 (1-3年)", _c1, hint: "2"),
          Padding(padding: EdgeInsets.only(bottom: 16, top: 0), child: Align(alignment: Alignment.centerLeft, child: Text("方案A: 收入替代法", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)))),
          _inputField("税前年收入", _c2, hint: "例如: 80000"),
          Padding(padding: EdgeInsets.only(bottom: 16, top: 8), child: Align(alignment: Alignment.centerLeft, child: Text("方案B: 开销覆盖法 (每月)", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)))),
          _inputField("1. 房贷或租房费", _c3, hint: "例如: 2000"),
          _inputField("2. 其他固定开销", _c4, hint: "例如: 1500"),
          _inputField("3. 每月生活费", _c5, hint: "例如: 1000"),
          Padding(padding: EdgeInsets.only(bottom: 16, top: 8), child: Align(alignment: Alignment.centerLeft, child: Text("额外一次性开销", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)))),
          _inputField("预留额外医疗/护理费", _c7, hint: "例如: 20000"),
        ]);
        
      case 'Disability':
        return Column(children: [
          _inputField("1. 税前月收入", _c1, hint: "例如: 6000"),
          _inputField("2. 每月房贷/租金", _c2, hint: "例如: 2000"),
          _inputField("3. 每月总开销", _c5, hint: "例如: 2000"),
        ]);
        
      case 'Health':
        return Column(children: [
          _inputField("年度牙医开销", _c1),
          _inputField("年度药物开销", _c2),
          _inputField("年度其他理疗", _c3),
        ]);
        
      default:
        return Container();
    }
  }

  Widget _inputField(String label, TextEditingController controller, {String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

// =======================
// 6. 智能测试页 (完整逻辑)
// =======================
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestionIndex = 0;
  
  Map<String, int> scores = {
    'ParLife': 0, 
    'TermLife': 0, 
    'Disability': 0, 
    'CI': 0,         
    'Health': 0,
    'Wealth': 0, 
  };

  List<String> userTags = [];

  final List<Question> questions = [
    // --- Q1: 生活状态 (增加了“退休养老”) ---
    Question(
      title: "Q1. 您目前的家庭或生活状态是？",
      options: [
        QuestionOption(
          label: "退休 / 准退休人士", 
          icon: "🌅", 
          impact: {'Wealth': 30, 'Health': 15, 'ParLife': 10}, 
          triggerReason: "高品质养老与年金流"
        ),
        QuestionOption(
          label: "有娃家庭 (家庭支柱)", 
          icon: "👨‍👩‍👧‍👦", 
          impact: {'TermLife': 25, 'CI': 10, 'ParLife': 5}, 
          triggerReason: "家庭责任与房贷风险"
        ),
        QuestionOption(
          label: "单身 / 二人世界", 
          icon: "👫", 
          impact: {'TermLife': 5, 'Disability': 10, 'Wealth': 10}, 
          triggerReason: "个人收入保障与储蓄"
        ),
      ],
    ),

    // --- Q2: 职业身份 (增加了“企业主”) ---
    Question(
      title: "Q2. 您的工作性质或主要收入来源？",
      options: [
        QuestionOption(
          label: "企业主 / 股东 (Business Owner)", 
          icon: "🏢", 
          // 企业主核心需求: 避税(ParLife), 债权人保护(Wealth/SegFund), 关键人风控(CI/Term)
          impact: {'ParLife': 30, 'Wealth': 25, 'CI': 10, 'Disability': 5}, 
          triggerReason: "企业税务优化(CDA)与资产隔离"
        ),
        QuestionOption(
          label: "自雇 / 自由职业", 
          icon: "💻", 
          impact: {'Disability': 25, 'Health': 15}, 
          triggerReason: "缺乏公司福利保障"
        ),
        QuestionOption(
          label: "公司雇员 (有福利)", 
          icon: "💼", 
          impact: {'Wealth': 10, 'ParLife': 5}, 
          triggerReason: "利用闲置资金理财"
        ),
        QuestionOption(
          label: "高净值被动收入 (投资/收租)", 
          icon: "💎", 
          impact: {'ParLife': 25, 'Wealth': 20, 'Disability': -10}, 
          triggerReason: "资产免税传承"
        ),
      ],
    ),

    // --- Q3: 财务担忧 (增加了“税务/资产传承”) ---
    Question(
      title: "Q3. 目前最让您担心的财务压力？",
      options: [
        QuestionOption(
          label: "税务太高 / 资产传承", 
          icon: "⚖️", 
          // 传承核心: ParLife(免税赔付), Wealth/SegFund(免Probate)
          impact: {'ParLife': 35, 'Wealth': 25}, 
          triggerReason: "规避遗产税与认证费"
        ),
        QuestionOption(
          label: "生大病没钱治 / 拖累家人", 
          icon: "🏥", 
          impact: {'CI': 30, 'Health': 10}, 
          triggerReason: "重疾康复基金"
        ),
        QuestionOption(
          label: "高额房贷 / 债务未清", 
          icon: "🏠", 
          impact: {'TermLife': 20, 'Disability': 10}, 
          triggerReason: "债务对冲"
        ),
        QuestionOption(
          label: "退休钱不够花", 
          icon: "📉", 
          impact: {'Wealth': 30, 'ParLife': 10}, 
          triggerReason: "长寿风险对冲"
        ),
      ],
    ),

    // --- Q4: 新增健康问题 (关键风控点) ---
    Question(
      title: "Q4. 您的健康状况如何？(这将影响产品选择)",
      options: [
        QuestionOption(
          label: "非常健康 (无吸烟)", 
          icon: "💪", 
          // 健康体适合买大额人寿/重疾，费率好
          impact: {'TermLife': 10, 'ParLife': 10, 'CI': 10}, 
          triggerReason: "利用优选身体素质锁定低费率"
        ),
        QuestionOption(
          label: "亚健康 (经常熬夜/压力大)", 
          icon: "😫", 
          // 亚健康是重疾险的强需求信号
          impact: {'CI': 20, 'Health': 10}, 
          triggerReason: "在身体亮红灯前尽早投保"
        ),
        QuestionOption(
          label: "有家族病史 (父母兄弟姐妹)", 
          icon: "🧬", 
          // 家族史极大增加重疾权重
          impact: {'CI': 35, 'TermLife': 10}, 
          triggerReason: "遗传风险规避 (家族病史)"
        ),
        QuestionOption(
          label: "有基础病 (三高/糖尿病等)", 
          icon: "💊", 
          // 有病很难买人寿/重疾，引导去买不需要体检的 Wealth/SegFund 或 保证承保的 Health
          impact: {'Wealth': 25, 'Health': 20, 'ParLife': -10, 'CI': -10}, 
          triggerReason: "关注免体检/保证承保产品"
        ),
      ],
    ),

    // --- Q5: 现金流 (保留) ---
    Question(
      title: "Q5. 如果不工作，现有积蓄能维持生活多久？",
      options: [
        QuestionOption(
          label: "5-10年以上 (资金充裕)", 
          icon: "🏦", 
          impact: {'ParLife': 15, 'Wealth': 15, 'Disability': -5}, 
          triggerReason: "资金冗余，需税务优化"
        ),
        QuestionOption(
          label: "1 年左右", 
          icon: "🧘", 
          impact: {'Disability': 10}, 
          triggerReason: "短期收入中断保护"
        ),
        QuestionOption(
          label: "少于 3 个月 (月光族)", 
          icon: "😱", 
          impact: {'Disability': 30, 'CI': 15}, 
          triggerReason: "现金流极度脆弱，急需收入替代"
        ),
      ],
    ),
  ];

  void _handleAnswer(QuestionOption option) {
    setState(() {
      option.impact.forEach((key, value) {
        scores[key] = (scores[key] ?? 0) + value;
      });
      if (option.triggerReason != null) {
        userTags.add(option.triggerReason!);
      }
    });

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(finalScores: scores, userTags: userTags)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var q = questions[currentQuestionIndex];
    double progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textDark), 
          onPressed: () => Navigator.pop(context)
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(AppColors.mintGreen),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "问题 ${currentQuestionIndex + 1}/${questions.length}",
                style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                q.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.3),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.separated(
                  itemCount: q.options.length,
                  separatorBuilder: (c, i) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final option = q.options[index];
                    return _buildOptionCard(option);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(QuestionOption option) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleAnswer(option),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, offset: Offset(0, 4))
            ]
          ),
          child: Row(
            children: [
              Text(option.icon, style: TextStyle(fontSize: 24)),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.label, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

// =======================
// 7. 结果推荐页 (适配 main.dart 架构)
// =======================
class ResultPage extends StatelessWidget {
  final Map<String, int> finalScores;
  final List<String> userTags;

  const ResultPage({super.key, required this.finalScores, required this.userTags});

  @override
  Widget build(BuildContext context) {
    var sortedKeys = finalScores.keys.toList(growable: false)
      ..sort((k1, k2) => finalScores[k2]!.compareTo(finalScores[k1]!));

    var topRecommendation = sortedKeys[0];
    
    if (finalScores[topRecommendation]! < 5) {
      topRecommendation = 'CI'; 
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              title: Text("你的专属方案", style: TextStyle(color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(gradient: AppColors.quizGradient),
                child: Center(
                  child: Icon(Icons.verified_user_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.white), 
              onPressed: () => Navigator.pop(context)
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("首选推荐 (Priority 1)", style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 10),
                  _buildTopResultCard(context, topRecommendation, userTags),

                  SizedBox(height: 30),
                  
                  Text("补充建议 (Recommended)", style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(height: 10),
                  _buildSecondaryCard(context, sortedKeys[1]),
                  _buildSecondaryCard(context, sortedKeys[2]),

                  SizedBox(height: 40),
                  
                  // 直接去计算器
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Map<String, dynamic> info = _getProductInfo(topRecommendation);
                      
                      // 修复逻辑：如果是 Wealth，进入新计算器；否则进入通用计算器
                      if (topRecommendation == 'Wealth') {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => CalculatorPage()));
                      } else {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => GeneralCalculatorPage(productKey: topRecommendation, title: info['title'])));
                      }
                    },
                    child: Text("去计算具体额度", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("返回首页", style: TextStyle(color: AppColors.textGrey)),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopResultCard(BuildContext context, String key, List<String> tags) {
    Map<String, dynamic> info = _getProductInfo(key);
    String reasonText = tags.isNotEmpty 
        ? "基于您关注：${tags.take(2).join('、')}..." 
        : "基于您的综合风险评估...";

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TabbedProductPage(productKey: key)));
      },
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primaryBlue.withOpacity(0.1), blurRadius: 20, offset: Offset(0, 10))],
          border: Border.all(color: AppColors.primaryBlue.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                  child: Icon(info['icon'], color: AppColors.primaryBlue, size: 32),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      SizedBox(height: 4),
                      Text(info['tag'], style: TextStyle(fontSize: 12, color: AppColors.mintGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF57F17)),
                  SizedBox(width: 8),
                  Expanded(child: Text(reasonText, style: TextStyle(fontSize: 12, color: Color(0xFFF57F17), height: 1.4))),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(info['desc'], style: TextStyle(fontSize: 15, color: AppColors.textDark, height: 1.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(BuildContext context, String key) {
    Map<String, dynamic> info = _getProductInfo(key);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => TabbedProductPage(productKey: key)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(info['icon'], color: AppColors.textGrey, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info['title'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text(info['shortDesc'], style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getProductInfo(String key) {
    switch (key) {
      case 'ParLife': 
        return {
          'title': '分红终身寿险', 
          'tag': '资产增值 · 遗产传承',
          'icon': Icons.account_balance, 
          'desc': '适合高净值家庭。除了终身保障，分红保险也是一种免税复利增长的资产类别。',
          'shortDesc': '资产增值与传承首选'
        };
      case 'TermLife':
        return {
          'title': '定期人寿保险',
          'tag': '高性价比 · 房贷必备',
          'icon': Icons.hourglass_top,
          'desc': '适合年轻家庭、房贷持有者。用最低的保费撬动最高的杠杆，提供坚实的财务安全网。',
          'shortDesc': '低保费高杠杆'
        };
      case 'Disability':
        return {
          'title': '伤残收入保险',
          'tag': '收入替代 · 现金流',
          'icon': Icons.accessible_forward,
          'desc': '如果因病无法工作，这就是您的“替补工资”，确保生活质量不下降。',
          'shortDesc': '生病无法工作时的工资单'
        };
      case 'CI':
        return {
          'title': '重大疾病保险',
          'tag': '康复基金 · 存钱防病',
          'icon': Icons.monitor_heart,
          'desc': '确诊癌症、心脏病等即赔付免税现金。无需动用养老金治病。',
          'shortDesc': '确诊即赔的康复备用金'
        };
      case 'Health':
        return {
          'title': '健康与牙科保险',
          'tag': '日常报销 · 提升体验',
          'icon': Icons.medical_services,
          'desc': '填补 OHIP 空白。报销处方药、洗牙、按摩，提升退休生活品质。',
          'shortDesc': '药费牙医报销'
        };
      case 'Wealth': 
        return {
          'title': '财富年金',
          'tag': '保证收入 · 避税',
          'icon': Icons.trending_up,
          'desc': '利用年金和保本基金，创造终身源源不断的现金流，无惧市场波动。',
          'shortDesc': '终身现金流'
        };
      default:
        return {'title': '综合规划', 'tag': '', 'icon': Icons.shield, 'desc': '', 'shortDesc': ''};
    }
  }
}