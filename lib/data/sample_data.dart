import 'package:jugaad_fix/models/jugaad_model.dart';

/// Central definition of categories so chips / dropdowns stay in sync.
class JugaadCategories {
  static const allKey = 'all';

  static const categories = <Map<String, String>>[
    {'key': 'power', 'label': 'Power Cut', 'emoji': '🔌'},
    {'key': 'internet', 'label': 'Internet', 'emoji': '📶'},
    {'key': 'kitchen', 'label': 'Kitchen', 'emoji': '🍳'},
    {'key': 'travel', 'label': 'Travel', 'emoji': '🚂'},
    {'key': 'money', 'label': 'Money', 'emoji': '💰'},
    {'key': 'health', 'label': 'Health', 'emoji': '🌿'},
    {'key': 'monsoon', 'label': 'Monsoon', 'emoji': '🌧️'},
    {'key': 'jugaad', 'label': 'Jugaad', 'emoji': '🔧'},
  ];

  static Map<String, String> byKey(String key) {
    return categories.firstWhere(
      (c) => c['key'] == key,
      orElse: () => categories.last,
    );
  }
}

/// Initial set of fun, Hinglish-style Jugaads.
final List<Jugaad> initialJugaads = [
  Jugaad(
    id: 'power-1',
    title: 'Plastic bottle se emergency lamp',
    categoryKey: 'power',
    categoryEmoji: '🔌',
    categoryLabel: 'Power Cut',
    shortDescription:
        'Mobile torch + pani ki bottle = full room light during load-shedding.',
    description:
        'Power cut aate hi panic mat ho. Mobile torch ko ulta rakho aur uske upar transparent pani ki bottle rakh do. Light diffuse hokar puri room mein fail jaati hai, bilkul emergency lamp jaisa feel aayega. Free ka jugaad, sirf bottle aur torch chahiye!',
    authorName: 'Society Ka Electrician',
    upvotes: 24,
  ),
  Jugaad(
    id: 'internet-1',
    title: 'Wi-Fi ka signal kam? Steel ka dabba lagao!',
    categoryKey: 'internet',
    categoryEmoji: '📶',
    categoryLabel: 'Internet',
    shortDescription:
        'Router ke peeche steel ka dabba rakhke signal ko room ki side redirect karo.',
    description:
        'Jahaan signal chahiye waha nahi, jahaan koi nahi baitha waha full network? Router ke peeche ek bada steel ka dabba ya tray rakho. Metal reflector ki tarah kaam karke signal ko aage ki direction mein bounce karta hai. Thoda desi, par kaafi kaam ka.',
    authorName: 'PG Waale Bhaiya',
    upvotes: 31,
  ),
  Jugaad(
    id: 'kitchen-1',
    title: 'Pyaaz kaanshu ke bina kaatna',
    categoryKey: 'kitchen',
    categoryEmoji: '🍳',
    categoryLabel: 'Kitchen',
    shortDescription:
        'Pyaaz fridge se seedha nikaalke kaato, aansu 70% kam ho jaate hain.',
    description:
        'Roz-roz pyaaz kaatke rona aadat bann gaya hai? Next time pyaaz ko 20–30 min fridge mein thanda hone do. Thande hone se jo gas release hoti hai wo slow ho jaati hai, aur aankhon mein irritation kaafi kam hota hai. Simple, scientific aur bilkul ghar ka jugaad.',
    authorName: 'Mummy Approved',
    upvotes: 18,
  ),
  Jugaad(
    id: 'travel-1',
    title: 'Train mein phone charge line full?',
    categoryKey: 'travel',
    categoryEmoji: '🚂',
    categoryLabel: 'Travel',
    shortDescription:
        'LED bulb wale socket se multi-plug laga ke apna charger chipka lo.',
    description:
        'Train mein charging point milna matlab lottery lagna. Agar side mein LED bulb wala socket dikhe, waha ek chota sa multi-plug adapter laga do. Bulb bhi chalega aur aapka charger bhi. Dhyaan rahe, heavy load mat lagao aur safety pe compromise mat karo.',
    authorName: 'Train Traveller',
    upvotes: 27,
  ),
  Jugaad(
    id: 'money-1',
    title: 'Loose change nahi? QR ka printout rakho',
    categoryKey: 'money',
    categoryEmoji: '💰',
    categoryLabel: 'Money',
    shortDescription:
        'Ghar ke gate pe apna UPI QR lagao — doodh wala, pani wala sab scan karke chale jaayenge.',
    description:
        'Roz subah change ke chakker mein dimaag kharab? Ghar ke gate ya fridge par apna UPI QR code ka printout chipka do. Doodh wala, paper wala, paani wala sab scan karke direct payment kar denge. Na wallet dhoondhna, na change ka scene.',
    authorName: 'Digital Dadi',
    upvotes: 19,
  ),
  Jugaad(
    id: 'health-1',
    title: 'Ghar ka mini standing desk',
    categoryKey: 'health',
    categoryEmoji: '🌿',
    categoryLabel: 'Health',
    shortDescription:
        'Ironing board ko upar karlo, laptop rakho aur khade hoke kaam karo.',
    description:
        'Back pain se pareshaan WFH warriors ke liye solid jugaad. Ghar ka ironing board height-adjustable hota hai. Use sabse upar set karo, upar ek patla bedsheet ya mat lagao aur laptop rakhke khade hoke kaam karo. Adjustable, foldable aur free standing desk!',
    authorName: 'WFH Ninja',
    upvotes: 22,
  ),
  Jugaad(
    id: 'monsoon-1',
    title: 'Gilli chapal se floor bachao',
    categoryKey: 'monsoon',
    categoryEmoji: '🌧️',
    categoryLabel: 'Monsoon',
    shortDescription:
        'Old newspaper se entry mat banaao, pura puddle catcher bana do.',
    description:
        'Baarish ke din, ghar ka floor slip-proof rakhna bhi ek art hai. Gate ke paas ek bada plastic ka tray ya purana cartoon box rakho, usme newspaper ki 3–4 layers bicha do. Ghar wale gilli chapal wahi utar ke andar aayein. Poora pani tray mein, floor safe.',
    authorName: 'Society Watchman',
    upvotes: 15,
  ),
  Jugaad(
    id: 'jugaad-1',
    title: 'Fan se instant cloth dryer',
    categoryKey: 'jugaad',
    categoryEmoji: '🔧',
    categoryLabel: 'Jugaad',
    shortDescription:
        'Fan ke neeche chair pe kapde spread karo, 30 min mein half dry.',
    description:
        'Jaldi-jee kapde sukhane hai? Ceiling fan ke neeche ek kursi ya table par kapde ko flat spread kar do. Fan full speed pe chalao. Hawa direct lagne se kapde bahar ki hawa se bhi jaldi sukh jaate hain. Bas itna dhyaan rakho ki fan balance kharab na ho.',
    authorName: 'Hostel Pro Max',
    upvotes: 29,
  ),
  Jugaad(
    id: 'kitchen-2',
    title: 'Masale ka dabba = phone stand',
    categoryKey: 'kitchen',
    categoryEmoji: '🍳',
    categoryLabel: 'Kitchen',
    shortDescription:
        'Recipe dekhte time phone ko masala box ke against tikhado.',
    description:
        'Cooking karte time phone haath mein rakhoge toh ya toh phone geelega ya recipe miss hogi. Ek mota masala ka dabba ya glass container rakho aur phone ko thoda angle pe uske against tikhado. Perfect eye-level recipe screen without fancy stand.',
    authorName: 'YouTube Chef',
    upvotes: 21,
  ),
  Jugaad(
    id: 'internet-2',
    title: 'Online exam during light cut',
    categoryKey: 'internet',
    categoryEmoji: '📶',
    categoryLabel: 'Internet',
    shortDescription:
        'Hotspot + inverter waale switchboard ko pehle hi test kar lo.',
    description:
        'Important online exam ya interview ho toh ek din pehle test run zaroor karo. Mobile hotspot setup karke dekhlo ki laptop easily connect ho raha hai ya nahi, aur inverter se kaunse plug pe backup milta hai. Exam ke din sirf switch change karna hoga, tension nahi.',
    authorName: 'Tension-Free Engineer',
    upvotes: 26,
  ),
  Jugaad(
    id: 'money-2',
    title: 'Impulse shopping rokne ka hack',
    categoryKey: 'money',
    categoryEmoji: '💰',
    categoryLabel: 'Money',
    shortDescription:
        'Cart mein add karo, 24 ghante baad hi kharido ya delete karo.',
    description:
        'Online sale dekhte hi haath phisal jaata hai? Rule banao – kuch bhi pasand aaye toh abhi ke abhi kharidna nahi, sirf cart mein daalna hai. 24 ghante baad dobara cart kholo, agar tab bhi item utna hi pasand hai toh lo, warna bina soch delete. Simple, par powerful.',
    authorName: 'Budget Baba',
    upvotes: 34,
  ),
  Jugaad(
    id: 'health-2',
    title: 'Screen break ka desi timer',
    categoryKey: 'health',
    categoryEmoji: '🌿',
    categoryLabel: 'Health',
    shortDescription:
        'Har chai break pe 20-20-20 rule follow karo, bas.',
    description:
        'Alag se reminder app install karne ki zaroorat nahi. Jab bhi chai ya pani lene uthte ho, tab 20-20-20 rule follow karo: 20 second ke liye 20 feet door kisi cheez ko dekho, har 20 minute mein ideally, par chai breaks se bhi kaafi relief milta hai.',
    authorName: 'Office Dost',
    upvotes: 17,
  ),
  Jugaad(
    id: 'monsoon-2',
    title: 'Phone ko baarish se bachao',
    categoryKey: 'monsoon',
    categoryEmoji: '🌧️',
    categoryLabel: 'Monsoon',
    shortDescription:
        'Transparent ziplock packet = emergency waterproof cover.',
    description:
        'Achanak se Mumbai-style baarish? Phone ko turant ek transparent ziplock packet mein daal do. Touch bhi thoda bahut kaam karta hai aur pani se protection bhi mil jaata hai. Waterproof case ke bina bhi kaafi safe ho jaata hai phone.',
    authorName: 'Rain Ready',
    upvotes: 23,
  ),
  Jugaad(
    id: 'travel-2',
    title: 'Backpack ko anti-theft banaao',
    categoryKey: 'travel',
    categoryEmoji: '🚂',
    categoryLabel: 'Travel',
    shortDescription:
        'Main zip ke puller mein chhota sa safety pin laga do.',
    description:
        'Crowded bus/train mein backpack ka zip khul jana common scene hai. Ek chhoti safety pin se main zip ke do pullers ko aapas mein lock kar do. Chor ko pin kholne mein time lagega aur aapko bhi pata chal jaayega ki koi chhed khaani ho rahi hai.',
    authorName: 'Traveller Didi',
    upvotes: 20,
  ),
  Jugaad(
    id: 'jugaad-2',
    title: 'Cloth hanger se laptop cooler',
    categoryKey: 'jugaad',
    categoryEmoji: '🔧',
    categoryLabel: 'Jugaad',
    shortDescription:
        'Metal hanger ko thoda bend karke laptop ko upar elevate karo.',
    description:
        'Laptop garam ho ke slow ho raha hai? Ek solid metal clothes hanger lo, usko U-shape mein thoda bend karo aur laptop ko uspe rakh do. Neeche se hawa pass hogi aur heating kam ho jaayegi. Simple stand, zero rupiya investment.',
    authorName: 'Engineering Minds',
    upvotes: 28,
  ),
];

