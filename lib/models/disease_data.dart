class DiseaseInfo {
  final String key;
  final Map<String, String> names;
  final Map<String, String> symptoms;
  final Map<String, String> causes;
  final Map<String, String> organicCare;
  final Map<String, String> chemicalTreatment;
  final Map<String, String> prevention;
  final String severity;

  const DiseaseInfo({
    required this.key,
    required this.names,
    required this.symptoms,
    required this.causes,
    required this.organicCare,
    required this.chemicalTreatment,
    required this.prevention,
    required this.severity,
  });

  String getName(String lang) => names[lang] ?? names['am'] ?? key;
  String getSymptoms(String lang) => symptoms[lang] ?? symptoms['am'] ?? '';
  String getCauses(String lang) => causes[lang] ?? causes['am'] ?? '';
  String getOrganicCare(String lang) => organicCare[lang] ?? organicCare['am'] ?? '';
  String getChemicalTreatment(String lang) => chemicalTreatment[lang] ?? chemicalTreatment['am'] ?? '';
  String getPrevention(String lang) => prevention[lang] ?? prevention['am'] ?? '';
}

class CoffeeDiseaseDatabase {
  static final Map<String, DiseaseInfo> diseases = {
    'Healthy': const DiseaseInfo(
      key: 'Healthy',
      severity: 'none',
      names: {
        'am': 'ጤናማ ቅጠል (ምንም በሽታ የለም)',
        'om': 'Baala Fayyaa (Dhukkuba hin qabu)',
        'en': 'Healthy Leaf (No Disease)',
      },
      symptoms: {
        'am': 'ቅጠሉ ጥቁር አረንጓዴ፣ የሚያብረቀርቅ እና ያለምንም ነጠብጣብ ወይም ጉዳት ያለ ነው።',
        'om': 'Baalli magariisa dukkanaawaa, kan ifuufi mallattoo miidhaa tokkollee kan hin qabne dha.',
        'en': 'Leaf is vibrant deep green, glossy, with no spots, lesions, or yellowing.',
      },
      causes: {
        'am': 'ተክሉ በቂ የተመጣጠነ ምግብ፣ ውሃ እና ተስማሚ ጥላ አግኝቷል።',
        'om': 'Biqiltuun nyaata madaalawaa, bishaan fi gaaddisa ga’aa argateera.',
        'en': 'The coffee tree receives optimal nutrition, moisture, and appropriate shade cover.',
      },
      organicCare: {
        'am': 'የማዳበሪያ ኮምፖስት አጠቃቀምን መቀጠል፤ በደረቅ ወቅት የኮሶ/ቅጠል ማልች (Mulch) ማድረግ።',
        'om': 'Koompostii itti fufinsaan fayyadamuu; yeroo gogaa baalaan biyyoosa uwwisuu (mulching).',
        'en': 'Maintain organic composting and apply dry mulch around the base during dry periods.',
      },
      chemicalTreatment: {
        'am': 'ምንም ዓይነት ኬሚካል አያስፈልገውም።',
        'om': 'Qoricha keemikaalaa tokkollee hin barbaadu.',
        'en': 'No chemical treatment needed.',
      },
      prevention: {
        'am': 'አሮጌ እና የደረቁ ቅርንጫፎችን በየወቅቱ መግረዝ እና አረም በወቅቱ ማረም።',
        'om': 'Daree dullomaafi gogaa yeroo yeroon baasuu fi aramaa yeroon aramuu.',
        'en': 'Regular pruning of old non-productive branches and timely weed management.',
      },
    ),

    'Leaf rust': const DiseaseInfo(
      key: 'Leaf rust',
      severity: 'high',
      names: {
        'am': 'የቡና ቅጠል ዝገት በሽታ (Rust)',
        'om': 'Dhukkuba Waaqoo Baala Bunaa (Leaf Rust)',
        'en': 'Coffee Leaf Rust (Hemileia vastatrix)',
      },
      symptoms: {
        'am': 'በቅጠሉ ስር ቢጫ ወይም ብርቱካናማ የዱቄት መልክ ያላቸው ነጠብጣቦች ይታያሉ፤ ቅጠሉ በፍጥነት ይረግፋል።',
        'om': 'Jala baalaatti kukkullaa keelloo ykn burtukaana dhumuutu mul’ata; baalli ni harca’a.',
        'en': 'Yellowish-orange powdery spore patches on leaf undersides, leading to premature defoliation.',
      },
      causes: {
        'am': 'ሄሚሊያ ቫስታትሪክስ (Hemileia vastatrix) ፈንገስ፤ በዝናብ ጠብታ እና ከፍተኛ እርጥበት ይስፋፋል።',
        'om': 'Fangaasii Hemileia vastatrix; dhangala’aa bokkaafi jiidhina guddaan babal’ata.',
        'en': 'Fungus Hemileia vastatrix, dispersed rapidly through rain splashes, high humidity, and wind.',
      },
      organicCare: {
        'am': 'አየር እና የፀሐይ ብርሃን በደንብ እንዲገባ ዛፎችን መግረዝ፤ በበሽታው የተጠቁትን ቅጠሎች ሰብስቦ ማቃጠል። ዝገት መቋቋም የሚችሉ ዝርያዎችን (74110፣ 74112) መትከል።',
        'om': 'Qilleensiifi aduun akka galuuf dameewwan ciruu; baala miidhame gubuudha.',
        'en': 'Prune trees to improve ventilation and sun penetration. Destroy dropped infected leaves.',
      },
      chemicalTreatment: {
        'am': 'የመዳብ ፀረ-ፈንገስ (Copper Oxychloride 50% WP) በ 1 ሄክታር ከ 3-4 ኪ.ግ ወይም Bayleton ዝናብ ከመግባቱ በፊት መርጨት።',
        'om': 'Qoricha koopparii (Copper Oxychloride) ykn Bayleton bokkaan eegaluun dura biifuu.',
        'en': 'Spray Copper Oxychloride 50% WP (3-4 kg/ha) or systemic Triadimefon (Bayleton).',
      },
      prevention: {
        'am': 'ጥላ ዛፎችን ሚዛናዊ ማድረግ (ከ 40-50% ጥላ) እና ተክሉን በፖታሽ ማዳበሪያ ማጠናከር።',
        'om': 'Gaaddisa madaalawaa eeguufi biqiltuun albuuda Pootaashiyemii akka argatu gochuu.',
        'en': 'Maintain balanced shade canopy (40-50%) and provide adequate potassium nutrition.',
      },
    ),

    'Cerscospora': const DiseaseInfo(
      key: 'Cerscospora',
      severity: 'medium',
      names: {
        'am': 'ሰርኮስፖራ / የቡናማ አይን በሽታ (Brown Eye)',
        'om': 'Dhukkuba Ija Boora Baala Bunaa (Cercospora)',
        'en': 'Brown Eye Spot (Cercospora coffeicola)',
      },
      symptoms: {
        'am': 'መሃላቸው ነጭ የሆኑ፣ ዙሪያቸው በቢጫ ቀለበት የታጠሩ ክብ ቡናማ ነጠብጣቦች በቅጠሉ ላይ ይታያሉ።',
        'om': 'Mallattoo bifa booraa jidduunsaa daalacha ta’ee naannoon isaa keelloo qabu uuma.',
        'en': 'Small brown circular spots with grayish-white centers surrounded by a chlorotic yellow halo.',
      },
      causes: {
        'am': 'የናይትሮጅን እጥረት፣ ተክሉ በፀሐይ በቀጥታ መመታት እና የአፈር ድህነት።',
        'om': 'Hanqina albuuda Naayitiroojiinii, aduun daran gubuu fi biyyoofi gabbina dhabuu.',
        'en': 'Nitrogen deficiency, soil nutrient depletion, and excessive direct sun exposure.',
      },
      organicCare: {
        'am': 'የጥላ ዛፎችን (እንደ ዋንዛ፣ ብርብራ) በቡና ማሳው ውስጥ ማብዛት፤ የተቦካ ማዳበሪያ መጨመር።',
        'om': 'Muka gaaddisaa dabaluu; koompostii naayitiroojiiniin badhaadhe kennuu.',
        'en': 'Establish native shade trees (e.g. Cordia africana); apply compost rich in nitrogen.',
      },
      chemicalTreatment: {
        'am': 'መዳብ ነክ ፀረ-ፈንገስ (Copper Hydroxide) ወይም ማንኮዜብ (Mancozeb 80% WP) መርጨት።',
        'om': 'Qoricha koopparii ykn Maankoozebii (Mancozeb 80% WP) biifuu.',
        'en': 'Apply protective copper fungicide or Mancozeb 80% WP (2-2.5 kg/ha).',
      },
      prevention: {
        'am': 'የቡና ችግኞች በመዋዕለ-ህፃናት እያሉ በቂ ጥላ እና ማዳበሪያ እንዲያገኙ ማድረግ።',
        'om': 'Biqiltuu irratti gaaddisaafi nyaata sirrii kennuun eeguu.',
        'en': 'Ensure seedlings receive sufficient mulch and shade.',
      },
    ),

    'Miner': const DiseaseInfo(
      key: 'Miner',
      severity: 'medium',
      names: {
        'am': 'የቡና ቅጠል ቆፋሪ ትል (Leaf Miner)',
        'om': 'Bilaacha Baala Qotu (Coffee Leaf Miner)',
        'en': 'Coffee Leaf Miner (Leucoptera coffeella)',
      },
      symptoms: {
        'am': 'በቅጠሉ ውስጥ ነጭ/ብርማ ጠመዝማዛ ዋሻዎች እና የደረቁ ቡናማ ሰፋፊ መስመሮች ይታያሉ።',
        'om': 'Kallattii baalaa keessatti boolla adii/daalacha fi sarara gogaa booraa uuma.',
        'en': 'Irregular serpentine blotches and silvery-white translucent mines inside the leaf tissue.',
      },
      causes: {
        'am': 'ትንሽ ነጭ የእሳት እራት (Moth) እንቁላል በቅጠሉ ላይ ስትጥል የሚፈለፈሉት ትሎች ቅጠሉን ይቦረቡራሉ።',
        'om': 'Bilaacha adii baala irratti hanqaaquu buustu; ilbiisni dhalatu baala keessa nyaata.',
        'en': 'Larvae of the tiny Leucoptera moth burrowing into and feeding on internal leaf mesophyll.',
      },
      organicCare: {
        'am': 'የተጎዱትን ቅጠሎች በእጅ ቆርጦ ማቃጠል፤ የተፈጥሮ አዳኝ ተርቦችን አለማጥፋት። የኒም (Neem) ዛፍ ቅጠል ውሃ ርጭት።',
        'om': 'Baala miidhame harkaan ciranii gubuu; qoricha uumamaa Neemi fayyadamuu.',
        'en': 'Hand-pick and burn mined leaves in early stages; spray biological neem extract.',
      },
      chemicalTreatment: {
        'am': 'ጉዳቱ ከ 25% በላይ ከደረሰ ስልታዊ ፀረ-ተባይ (Chlorpyrifos ወይም Dimethoate) መርጨት።',
        'om': 'Yoo miidhaan 25% ol ta’e qoricha ilbiisaa (Dimethoate ykn Chlorpyrifos) biifuu.',
        'en': 'If infestation exceeds 25%, apply systemic insecticide (e.g. Chlorpyrifos).',
      },
      prevention: {
        'am': 'ከመጠን ያለፈ የፀሐይ ሙቀትን በዛፍ ጥላ መከላከል፤ ተፈጥሯዊ የነፍሳት ሚዛንን መጠበቅ።',
        'om': 'Ho’a aduu cimaa ittisuuf gaaddisa uumuu; madaallii uumamaa eeguu.',
        'en': 'Reduce drought stress with proper shade management and avoid insecticide overuse.',
      },
    ),

    'Phoma': const DiseaseInfo(
      key: 'Phoma',
      severity: 'high',
      names: {
        'am': 'ፎማ / የቅጠል ጫፍ መድረቅ በሽታ (Phoma Dieback)',
        'om': 'Dhukkuba Fomaa / Qarqara Baalaa Gorsu (Phoma)',
        'en': 'Phoma Leaf Spot & Dieback (Phoma costaricensis)',
      },
      symptoms: {
        'am': 'የቅጠሉ ጫፎች እና ጠርዞች ጠቁረው ይደርቃሉ፤ ቅርንጫፎቹ ከጫፍ ወደ ስር ይደርቃሉ።',
        'om': 'Fiixeen baalaafi qarqari isaa gogee gara dhabamaatti deema.',
        'en': 'Dark brown necrotic lesions on leaf margins and tips; severe branch dieback.',
      },
      causes: {
        'am': 'ቀዝቃዛ እና ኃይለኛ ንፋስ፣ ከፍተኛ ከፍታ (ከ 1900 ሜትር በላይ) እና ዝቅተኛ የሙቀት መጠን።',
        'om': 'Qilleensa qorraafi bubbee cimaa, bakka olka’aa (lafa baddaa).',
        'en': 'Cold, windy conditions at high altitudes (>1900m) with cold rain and frost.',
      },
      organicCare: {
        'am': 'የንፋስ መከላከያ ዛፎችን በቡና እርሻው ዙሪያ መትከል፤ የደረቁ ቅርንጫፎችን ቆርጦ ማቃጠል።',
        'om': 'Muka bubbee ittisu naannoo bunaatti dhaabuu; daree gogaa ciranii gubuu.',
        'en': 'Plant dense windbreaks around the plantation; sanitize by pruning dead tips.',
      },
      chemicalTreatment: {
        'am': 'መዳብ ነክ ፈንገስ መድኃኒት በዝናብ መጀመሪያ ወቅት መርጨት።',
        'om': 'Qoricha koopparii bokkaan yeroo eegalu biifuu.',
        'en': 'Preventive copper-based fungicides during early rainy, cold spells.',
      },
      prevention: {
        'am': 'የንፋስ መከላከያ አጥር ማበጀት እና ተክሉን በፎስፈረስ እና ፖታሽ ማጠናከር።',
        'om': 'Dahoo bubbee uumuufi albuuda biyyoo madaalawaa gochuu.',
        'en': 'Establish effective vegetative windbreaks; ensure balanced phosphorus.',
      },
    ),
  };

  static DiseaseInfo get(String key) {
    return diseases[key] ?? diseases['Healthy']!;
  }
}
