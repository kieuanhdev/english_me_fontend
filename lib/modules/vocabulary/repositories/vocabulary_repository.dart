import 'package:englishme/modules/vocabulary/models/vocabulary_model.dart';

class VocabularyRepository {
  Future<List<VocabularyTopic>> getTopics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _topics;
  }

  Future<List<VocabularyWord>> getWordsByTopic(String topicId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _words.where((w) => w.topicId == topicId).toList();
  }
}

const _topics = [
  VocabularyTopic(
    id: 'animals',
    name: 'Động vật',
    nameEn: 'Animals',
    icon: '🐾',
    wordCount: 10,
    level: VocabularyLevel.a1,
    colorHex: '#4CAF50',
  ),
  VocabularyTopic(
    id: 'food',
    name: 'Thức ăn',
    nameEn: 'Food & Drink',
    icon: '🍽️',
    wordCount: 10,
    level: VocabularyLevel.a1,
    colorHex: '#FF9800',
  ),
  VocabularyTopic(
    id: 'travel',
    name: 'Du lịch',
    nameEn: 'Travel',
    icon: '✈️',
    wordCount: 10,
    level: VocabularyLevel.a2,
    colorHex: '#2196F3',
  ),
  VocabularyTopic(
    id: 'business',
    name: 'Kinh doanh',
    nameEn: 'Business',
    icon: '💼',
    wordCount: 10,
    level: VocabularyLevel.b1,
    colorHex: '#9C27B0',
  ),
  VocabularyTopic(
    id: 'technology',
    name: 'Công nghệ',
    nameEn: 'Technology',
    icon: '💻',
    wordCount: 10,
    level: VocabularyLevel.b2,
    colorHex: '#00BCD4',
  ),
  VocabularyTopic(
    id: 'health',
    name: 'Sức khỏe',
    nameEn: 'Health',
    icon: '🏥',
    wordCount: 10,
    level: VocabularyLevel.a2,
    colorHex: '#F44336',
  ),
];

const _words = [
  // Animals
  VocabularyWord(
    id: 'a1', topicId: 'animals', word: 'elephant', pronunciation: '/ˈel.ɪ.fənt/',
    partOfSpeech: 'n', definitionVi: 'con voi', definitionEn: 'A very large grey animal with a long nose',
    exampleSentence: 'The elephant sprayed water with its trunk.',
    exampleTranslation: 'Con voi phun nước bằng cái vòi của nó.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'a2', topicId: 'animals', word: 'dolphin', pronunciation: '/ˈdɒl.fɪn/',
    partOfSpeech: 'n', definitionVi: 'cá heo', definitionEn: 'A highly intelligent marine mammal',
    exampleSentence: 'Dolphins are known for their intelligence.',
    exampleTranslation: 'Cá heo nổi tiếng với trí thông minh của chúng.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'a3', topicId: 'animals', word: 'cheetah', pronunciation: '/ˈtʃiː.tə/',
    partOfSpeech: 'n', definitionVi: 'báo săn', definitionEn: 'The fastest land animal on Earth',
    exampleSentence: 'A cheetah can run at 112 km/h.',
    exampleTranslation: 'Báo săn có thể chạy với tốc độ 112 km/h.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'a4', topicId: 'animals', word: 'penguin', pronunciation: '/ˈpeŋ.ɡwɪn/',
    partOfSpeech: 'n', definitionVi: 'chim cánh cụt', definitionEn: 'A flightless black-and-white bird',
    exampleSentence: 'Penguins live in the Southern Hemisphere.',
    exampleTranslation: 'Chim cánh cụt sống ở Nam bán cầu.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'a5', topicId: 'animals', word: 'crocodile', pronunciation: '/ˈkrɒk.ə.daɪl/',
    partOfSpeech: 'n', definitionVi: 'cá sấu', definitionEn: 'A large reptile living near water',
    exampleSentence: 'Crocodiles are ancient predators.',
    exampleTranslation: 'Cá sấu là những loài săn mồi cổ xưa.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'a6', topicId: 'animals', word: 'gorilla', pronunciation: '/ɡəˈrɪl.ə/',
    partOfSpeech: 'n', definitionVi: 'khỉ đột', definitionEn: 'The largest living primate',
    exampleSentence: 'Gorillas share 98% of DNA with humans.',
    exampleTranslation: 'Khỉ đột chia sẻ 98% ADN với con người.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'a7', topicId: 'animals', word: 'butterfly', pronunciation: '/ˈbʌt.ə.flaɪ/',
    partOfSpeech: 'n', definitionVi: 'con bướm', definitionEn: 'An insect with colorful wings',
    exampleSentence: 'A butterfly landed on the flower.',
    exampleTranslation: 'Một con bướm đậu lên bông hoa.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'a8', topicId: 'animals', word: 'tortoise', pronunciation: '/ˈtɔː.tɪs/',
    partOfSpeech: 'n', definitionVi: 'rùa cạn', definitionEn: 'A slow-moving reptile with a hard shell',
    exampleSentence: 'Tortoises can live for over 100 years.',
    exampleTranslation: 'Rùa cạn có thể sống hơn 100 năm.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'a9', topicId: 'animals', word: 'parrot', pronunciation: '/ˈpær.ət/',
    partOfSpeech: 'n', definitionVi: 'con vẹt', definitionEn: 'A colorful bird that can mimic speech',
    exampleSentence: 'The parrot repeated every word I said.',
    exampleTranslation: 'Con vẹt lặp lại mọi lời tôi nói.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'a10', topicId: 'animals', word: 'hedgehog', pronunciation: '/ˈhedʒ.hɒɡ/',
    partOfSpeech: 'n', definitionVi: 'nhím', definitionEn: 'A small mammal with sharp spines',
    exampleSentence: 'The hedgehog curled into a ball.',
    exampleTranslation: 'Con nhím cuộn tròn thành quả bóng.', level: VocabularyLevel.a2,
  ),

  // Food
  VocabularyWord(
    id: 'f1', topicId: 'food', word: 'avocado', pronunciation: '/ˌæv.əˈkɑː.doʊ/',
    partOfSpeech: 'n', definitionVi: 'quả bơ', definitionEn: 'A green pear-shaped fruit with creamy flesh',
    exampleSentence: 'She made guacamole from fresh avocados.',
    exampleTranslation: 'Cô ấy làm guacamole từ quả bơ tươi.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'f2', topicId: 'food', word: 'cuisine', pronunciation: '/kwɪˈziːn/',
    partOfSpeech: 'n', definitionVi: 'ẩm thực', definitionEn: 'A style or method of cooking',
    exampleSentence: 'Italian cuisine is famous worldwide.',
    exampleTranslation: 'Ẩm thực Ý nổi tiếng trên toàn thế giới.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'f3', topicId: 'food', word: 'ingredient', pronunciation: '/ɪnˈɡriː.di.ənt/',
    partOfSpeech: 'n', definitionVi: 'nguyên liệu', definitionEn: 'A food item used in a recipe',
    exampleSentence: 'What ingredients do you need for this dish?',
    exampleTranslation: 'Bạn cần những nguyên liệu gì cho món này?', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'f4', topicId: 'food', word: 'appetizer', pronunciation: '/ˈæp.ɪ.taɪ.zər/',
    partOfSpeech: 'n', definitionVi: 'món khai vị', definitionEn: 'A small dish served before the main course',
    exampleSentence: 'We ordered soup as an appetizer.',
    exampleTranslation: 'Chúng tôi gọi súp làm món khai vị.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'f5', topicId: 'food', word: 'sauté', pronunciation: '/ˈsoʊ.teɪ/',
    partOfSpeech: 'v', definitionVi: 'xào', definitionEn: 'To fry food quickly in a little hot fat',
    exampleSentence: 'Sauté the garlic until golden brown.',
    exampleTranslation: 'Xào tỏi cho đến khi vàng nâu.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'f6', topicId: 'food', word: 'beverage', pronunciation: '/ˈbev.ər.ɪdʒ/',
    partOfSpeech: 'n', definitionVi: 'đồ uống', definitionEn: 'A drink, especially one other than water',
    exampleSentence: 'What beverages do you have on the menu?',
    exampleTranslation: 'Thực đơn của bạn có những đồ uống gì?', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'f7', topicId: 'food', word: 'marinate', pronunciation: '/ˈmær.ɪ.neɪt/',
    partOfSpeech: 'v', definitionVi: 'ướp', definitionEn: 'To soak food in a seasoned liquid',
    exampleSentence: 'Marinate the chicken overnight.',
    exampleTranslation: 'Ướp gà qua đêm.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'f8', topicId: 'food', word: 'dessert', pronunciation: '/dɪˈzɜːt/',
    partOfSpeech: 'n', definitionVi: 'tráng miệng', definitionEn: 'Sweet food eaten at the end of a meal',
    exampleSentence: 'Would you like some dessert?',
    exampleTranslation: 'Bạn có muốn dùng tráng miệng không?', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 'f9', topicId: 'food', word: 'nutritious', pronunciation: '/njuːˈtrɪʃ.əs/',
    partOfSpeech: 'adj', definitionVi: 'bổ dưỡng', definitionEn: 'Containing substances needed for good health',
    exampleSentence: 'Vegetables are nutritious and low in calories.',
    exampleTranslation: 'Rau củ bổ dưỡng và ít calo.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'f10', topicId: 'food', word: 'gourmet', pronunciation: '/ˈɡʊər.meɪ/',
    partOfSpeech: 'adj', definitionVi: 'thượng hạng', definitionEn: 'Of high quality food and cooking',
    exampleSentence: 'This is a gourmet restaurant.',
    exampleTranslation: 'Đây là nhà hàng thượng hạng.', level: VocabularyLevel.b2,
  ),

  // Travel
  VocabularyWord(
    id: 't1', topicId: 'travel', word: 'itinerary', pronunciation: '/aɪˈtɪn.ər.er.i/',
    partOfSpeech: 'n', definitionVi: 'lịch trình', definitionEn: 'A planned route or journey',
    exampleSentence: 'Please send me your travel itinerary.',
    exampleTranslation: 'Vui lòng gửi cho tôi lịch trình du lịch của bạn.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 't2', topicId: 'travel', word: 'passport', pronunciation: '/ˈpɑːs.pɔːt/',
    partOfSpeech: 'n', definitionVi: 'hộ chiếu', definitionEn: 'An official document for international travel',
    exampleSentence: 'Do not forget your passport.',
    exampleTranslation: 'Đừng quên hộ chiếu của bạn.', level: VocabularyLevel.a1,
  ),
  VocabularyWord(
    id: 't3', topicId: 'travel', word: 'accommodation', pronunciation: '/əˌkɒm.əˈdeɪ.ʃən/',
    partOfSpeech: 'n', definitionVi: 'chỗ ở', definitionEn: 'A place where someone can stay',
    exampleSentence: 'Have you booked your accommodation?',
    exampleTranslation: 'Bạn đã đặt chỗ ở chưa?', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 't4', topicId: 'travel', word: 'departure', pronunciation: '/dɪˈpɑː.tʃər/',
    partOfSpeech: 'n', definitionVi: 'khởi hành', definitionEn: 'The act of leaving a place',
    exampleSentence: 'The departure time is 08:30.',
    exampleTranslation: 'Giờ khởi hành là 08:30.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 't5', topicId: 'travel', word: 'destination', pronunciation: '/ˌdes.tɪˈneɪ.ʃən/',
    partOfSpeech: 'n', definitionVi: 'điểm đến', definitionEn: 'The place you are traveling to',
    exampleSentence: 'Paris is a popular tourist destination.',
    exampleTranslation: 'Paris là điểm đến du lịch phổ biến.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 't6', topicId: 'travel', word: 'turbulence', pronunciation: '/ˈtɜː.bjʊ.ləns/',
    partOfSpeech: 'n', definitionVi: 'nhiễu loạn (không khí)', definitionEn: 'Irregular air movements during flight',
    exampleSentence: 'The flight experienced heavy turbulence.',
    exampleTranslation: 'Chuyến bay gặp nhiều nhiễu loạn mạnh.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 't7', topicId: 'travel', word: 'souvenir', pronunciation: '/ˌsuː.vəˈnɪər/',
    partOfSpeech: 'n', definitionVi: 'đồ lưu niệm', definitionEn: 'A thing kept as a reminder of a place',
    exampleSentence: 'I bought souvenirs for my family.',
    exampleTranslation: 'Tôi mua đồ lưu niệm cho gia đình.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 't8', topicId: 'travel', word: 'layover', pronunciation: '/ˈleɪ.oʊ.vər/',
    partOfSpeech: 'n', definitionVi: 'quá cảnh', definitionEn: 'A stop during a journey',
    exampleSentence: 'We have a 3-hour layover in Dubai.',
    exampleTranslation: 'Chúng tôi có 3 giờ quá cảnh ở Dubai.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 't9', topicId: 'travel', word: 'customs', pronunciation: '/ˈkʌs.təmz/',
    partOfSpeech: 'n', definitionVi: 'hải quan', definitionEn: 'The place at a border where goods are checked',
    exampleSentence: 'You must declare items at customs.',
    exampleTranslation: 'Bạn phải khai báo hàng hóa tại hải quan.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 't10', topicId: 'travel', word: 'backpacker', pronunciation: '/ˈbæk.pæk.ər/',
    partOfSpeech: 'n', definitionVi: 'người du lịch balo', definitionEn: 'A traveler with minimal budget',
    exampleSentence: 'She traveled Southeast Asia as a backpacker.',
    exampleTranslation: 'Cô ấy du lịch Đông Nam Á bằng balo.', level: VocabularyLevel.b1,
  ),

  // Business
  VocabularyWord(
    id: 'b1', topicId: 'business', word: 'negotiate', pronunciation: '/nɪˈɡoʊ.ʃi.eɪt/',
    partOfSpeech: 'v', definitionVi: 'đàm phán', definitionEn: 'To discuss to reach an agreement',
    exampleSentence: 'We need to negotiate the contract terms.',
    exampleTranslation: 'Chúng ta cần đàm phán các điều khoản hợp đồng.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'b2', topicId: 'business', word: 'revenue', pronunciation: '/ˈrev.ən.juː/',
    partOfSpeech: 'n', definitionVi: 'doanh thu', definitionEn: 'Income generated from business activities',
    exampleSentence: 'The company\'s revenue grew by 20%.',
    exampleTranslation: 'Doanh thu của công ty tăng 20%.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'b3', topicId: 'business', word: 'entrepreneur', pronunciation: '/ˌɒn.trə.prəˈnɜːr/',
    partOfSpeech: 'n', definitionVi: 'doanh nhân', definitionEn: 'A person who starts a business',
    exampleSentence: 'She became a successful entrepreneur at 25.',
    exampleTranslation: 'Cô ấy trở thành doanh nhân thành công năm 25 tuổi.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'b4', topicId: 'business', word: 'merger', pronunciation: '/ˈmɜː.dʒər/',
    partOfSpeech: 'n', definitionVi: 'sáp nhập', definitionEn: 'Combination of two companies into one',
    exampleSentence: 'The merger was approved by shareholders.',
    exampleTranslation: 'Vụ sáp nhập được các cổ đông phê duyệt.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'b5', topicId: 'business', word: 'stakeholder', pronunciation: '/ˈsteɪk.hoʊl.dər/',
    partOfSpeech: 'n', definitionVi: 'bên liên quan', definitionEn: 'A person with an interest in a business',
    exampleSentence: 'All stakeholders attended the meeting.',
    exampleTranslation: 'Tất cả các bên liên quan đã tham dự cuộc họp.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'b6', topicId: 'business', word: 'fiscal', pronunciation: '/ˈfɪs.kəl/',
    partOfSpeech: 'adj', definitionVi: 'tài chính (nhà nước)', definitionEn: 'Relating to government finances',
    exampleSentence: 'The fiscal year ends in December.',
    exampleTranslation: 'Năm tài chính kết thúc vào tháng 12.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'b7', topicId: 'business', word: 'leverage', pronunciation: '/ˈlev.ər.ɪdʒ/',
    partOfSpeech: 'v', definitionVi: 'tận dụng', definitionEn: 'To use something to maximum advantage',
    exampleSentence: 'We can leverage this partnership.',
    exampleTranslation: 'Chúng ta có thể tận dụng mối quan hệ đối tác này.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'b8', topicId: 'business', word: 'dividend', pronunciation: '/ˈdɪv.ɪ.dend/',
    partOfSpeech: 'n', definitionVi: 'cổ tức', definitionEn: 'A share of company profits paid to shareholders',
    exampleSentence: 'Shareholders receive quarterly dividends.',
    exampleTranslation: 'Cổ đông nhận cổ tức hàng quý.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'b9', topicId: 'business', word: 'benchmark', pronunciation: '/ˈbentʃ.mɑːk/',
    partOfSpeech: 'n', definitionVi: 'tiêu chuẩn so sánh', definitionEn: 'A standard used to evaluate performance',
    exampleSentence: 'Use this as a benchmark for quality.',
    exampleTranslation: 'Dùng điều này làm tiêu chuẩn về chất lượng.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'b10', topicId: 'business', word: 'scalable', pronunciation: '/ˈskeɪ.lə.bəl/',
    partOfSpeech: 'adj', definitionVi: 'có thể mở rộng', definitionEn: 'Able to grow to handle increased demand',
    exampleSentence: 'The business model must be scalable.',
    exampleTranslation: 'Mô hình kinh doanh phải có thể mở rộng.', level: VocabularyLevel.b2,
  ),

  // Technology
  VocabularyWord(
    id: 'tech1', topicId: 'technology', word: 'algorithm', pronunciation: '/ˈæl.ɡə.rɪ.ðəm/',
    partOfSpeech: 'n', definitionVi: 'thuật toán', definitionEn: 'A step-by-step procedure for calculations',
    exampleSentence: 'The search algorithm returned fast results.',
    exampleTranslation: 'Thuật toán tìm kiếm trả về kết quả nhanh.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'tech2', topicId: 'technology', word: 'bandwidth', pronunciation: '/ˈbænd.wɪdθ/',
    partOfSpeech: 'n', definitionVi: 'băng thông', definitionEn: 'The capacity of a network connection',
    exampleSentence: 'Streaming video requires high bandwidth.',
    exampleTranslation: 'Xem video trực tuyến cần băng thông cao.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'tech3', topicId: 'technology', word: 'encryption', pronunciation: '/ɪnˈkrɪp.ʃən/',
    partOfSpeech: 'n', definitionVi: 'mã hóa', definitionEn: 'Converting data into a coded form for security',
    exampleSentence: 'The message uses end-to-end encryption.',
    exampleTranslation: 'Tin nhắn sử dụng mã hóa đầu cuối.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'tech4', topicId: 'technology', word: 'interface', pronunciation: '/ˈɪn.tə.feɪs/',
    partOfSpeech: 'n', definitionVi: 'giao diện', definitionEn: 'A point where systems or users interact',
    exampleSentence: 'The user interface is clean and intuitive.',
    exampleTranslation: 'Giao diện người dùng sạch sẽ và trực quan.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'tech5', topicId: 'technology', word: 'latency', pronunciation: '/ˈleɪ.tən.si/',
    partOfSpeech: 'n', definitionVi: 'độ trễ', definitionEn: 'The delay before data transfer begins',
    exampleSentence: 'Low latency is crucial for gaming.',
    exampleTranslation: 'Độ trễ thấp rất quan trọng cho game.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'tech6', topicId: 'technology', word: 'repository', pronunciation: '/rɪˈpɒz.ɪ.tər.i/',
    partOfSpeech: 'n', definitionVi: 'kho lưu trữ', definitionEn: 'A storage location for code or data',
    exampleSentence: 'Push your code to the repository.',
    exampleTranslation: 'Đẩy code của bạn lên kho lưu trữ.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'tech7', topicId: 'technology', word: 'prototype', pronunciation: '/ˈproʊ.tə.taɪp/',
    partOfSpeech: 'n', definitionVi: 'nguyên mẫu', definitionEn: 'An early model of a product for testing',
    exampleSentence: 'We built a prototype before the final product.',
    exampleTranslation: 'Chúng tôi xây dựng nguyên mẫu trước sản phẩm cuối.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'tech8', topicId: 'technology', word: 'deployment', pronunciation: '/dɪˈplɔɪ.mənt/',
    partOfSpeech: 'n', definitionVi: 'triển khai', definitionEn: 'The process of releasing software to users',
    exampleSentence: 'Deployment is scheduled for Friday.',
    exampleTranslation: 'Triển khai được lên lịch vào thứ Sáu.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'tech9', topicId: 'technology', word: 'scalability', pronunciation: '/ˌskeɪ.ləˈbɪl.ɪ.ti/',
    partOfSpeech: 'n', definitionVi: 'khả năng mở rộng', definitionEn: 'Ability of a system to handle growth',
    exampleSentence: 'Scalability is key for cloud services.',
    exampleTranslation: 'Khả năng mở rộng là chìa khóa cho dịch vụ đám mây.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'tech10', topicId: 'technology', word: 'virtualization', pronunciation: '/ˌvɜː.tʃu.ə.laɪˈzeɪ.ʃən/',
    partOfSpeech: 'n', definitionVi: 'ảo hóa', definitionEn: 'Creating virtual versions of hardware or software',
    exampleSentence: 'Virtualization reduces hardware costs.',
    exampleTranslation: 'Ảo hóa giúp giảm chi phí phần cứng.', level: VocabularyLevel.c1,
  ),

  // Health
  VocabularyWord(
    id: 'h1', topicId: 'health', word: 'symptom', pronunciation: '/ˈsɪmp.təm/',
    partOfSpeech: 'n', definitionVi: 'triệu chứng', definitionEn: 'A sign that shows you are ill',
    exampleSentence: 'Fever is a common symptom of flu.',
    exampleTranslation: 'Sốt là triệu chứng phổ biến của cúm.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'h2', topicId: 'health', word: 'vaccination', pronunciation: '/ˌvæk.sɪˈneɪ.ʃən/',
    partOfSpeech: 'n', definitionVi: 'tiêm chủng', definitionEn: 'Injection to protect against disease',
    exampleSentence: 'Get your annual flu vaccination.',
    exampleTranslation: 'Tiêm chủng cúm hàng năm của bạn.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'h3', topicId: 'health', word: 'diagnosis', pronunciation: '/ˌdaɪ.əɡˈnoʊ.sɪs/',
    partOfSpeech: 'n', definitionVi: 'chẩn đoán', definitionEn: 'Identifying a disease from its symptoms',
    exampleSentence: 'The diagnosis came back negative.',
    exampleTranslation: 'Kết quả chẩn đoán âm tính.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'h4', topicId: 'health', word: 'prescription', pronunciation: '/prɪˈskrɪp.ʃən/',
    partOfSpeech: 'n', definitionVi: 'đơn thuốc', definitionEn: 'A written order for medicine from a doctor',
    exampleSentence: 'You need a prescription for this medicine.',
    exampleTranslation: 'Bạn cần đơn thuốc cho loại thuốc này.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'h5', topicId: 'health', word: 'immune', pronunciation: '/ɪˈmjuːn/',
    partOfSpeech: 'adj', definitionVi: 'miễn dịch', definitionEn: 'Protected against a particular disease',
    exampleSentence: 'Children become immune after vaccination.',
    exampleTranslation: 'Trẻ em có miễn dịch sau khi tiêm chủng.', level: VocabularyLevel.b1,
  ),
  VocabularyWord(
    id: 'h6', topicId: 'health', word: 'cardiovascular', pronunciation: '/ˌkɑː.di.oʊˈvæs.kjʊ.lər/',
    partOfSpeech: 'adj', definitionVi: 'tim mạch', definitionEn: 'Relating to the heart and blood vessels',
    exampleSentence: 'Exercise improves cardiovascular health.',
    exampleTranslation: 'Tập thể dục cải thiện sức khỏe tim mạch.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'h7', topicId: 'health', word: 'allergic', pronunciation: '/əˈlɜː.dʒɪk/',
    partOfSpeech: 'adj', definitionVi: 'dị ứng', definitionEn: 'Having an allergy to something',
    exampleSentence: 'I am allergic to peanuts.',
    exampleTranslation: 'Tôi bị dị ứng với đậu phộng.', level: VocabularyLevel.a2,
  ),
  VocabularyWord(
    id: 'h8', topicId: 'health', word: 'chronic', pronunciation: '/ˈkrɒn.ɪk/',
    partOfSpeech: 'adj', definitionVi: 'mãn tính', definitionEn: 'A condition lasting for a long time',
    exampleSentence: 'He suffers from chronic back pain.',
    exampleTranslation: 'Anh ấy bị đau lưng mãn tính.', level: VocabularyLevel.b2,
  ),
  VocabularyWord(
    id: 'h9', topicId: 'health', word: 'rehabilitation', pronunciation: '/ˌriː.həˌbɪl.ɪˈteɪ.ʃən/',
    partOfSpeech: 'n', definitionVi: 'phục hồi chức năng', definitionEn: 'Treatment to restore health after illness',
    exampleSentence: 'Physical rehabilitation helped him walk again.',
    exampleTranslation: 'Phục hồi chức năng giúp anh ấy đi lại được.', level: VocabularyLevel.c1,
  ),
  VocabularyWord(
    id: 'h10', topicId: 'health', word: 'sedentary', pronunciation: '/ˈsed.ən.ter.i/',
    partOfSpeech: 'adj', definitionVi: 'ít vận động', definitionEn: 'Characterized by much sitting and little activity',
    exampleSentence: 'A sedentary lifestyle increases health risks.',
    exampleTranslation: 'Lối sống ít vận động làm tăng nguy cơ sức khỏe.', level: VocabularyLevel.c1,
  ),
];
