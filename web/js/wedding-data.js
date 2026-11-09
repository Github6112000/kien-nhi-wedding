/**
 * Toàn bộ nội dung thiệp nằm ở đây — sửa file này, không cần đụng HTML/CSS.
 *
 * Cá nhân hoá tên khách trên phong bì bằng tham số URL:
 *   https://<ten-mien>/?khach=Anh%20Minh%20%26%20Ch%E1%BB%8B%20Lan
 * Không có tham số thì hiển thị `defaultGuest`.
 */
const wedding = {
  couple: {
    groom: "Nguyễn Đình Kiên",
    bride: "Nguyễn Phương Nhi",
    groomShort: "Đình Kiên",
    brideShort: "Phương Nhi"
  },

  story: {
    text:
      "Không sớm một bước, không muộn một bước, chúng ta vừa vặn thuộc về nhau. " +
      "Ngay phút giây này, bàn tay này sẽ nắm chặt bàn tay ấy, cho đến tận cùng"
  },

  people: {
    title: "Hai trái tim, một mái nhà",
    groom: { role: "Chú rể", photo: "assets/images/chu-re.jpg" },
    bride: { role: "Cô dâu", photo: "assets/images/co-dau.jpg" }
  },

  defaultGuest: "Quý khách",

  date: {
    iso: "2026-11-29",              // dùng để dựng lịch tuần
    display: "29.11.2026",
    dayOfWeek: "Chủ Nhật",
    monthLabel: "Tháng Mười Một"
  },

  greeting: {
    title: "Thân gửi gia đình\n& bạn bè!",
    text:
      "Trân trọng kính mời Quý khách đến chung vui cùng gia đình chúng tôi " +
      "trong ngày trọng đại — ngày hai chúng tôi chính thức về chung một nhà " +
      "và viết tiếp chương mới của câu chuyện tình yêu."
  },

  reception: {
    venue: "Mipec Tây Sơn",
    address: "229 Phố Tây Sơn, Phường Kim Liên, Hà Nội",
    mapsQuery: "Trung Tâm Tiệc Cưới Mipec Tây Sơn, 229 Tây Sơn, Kim Liên, Hà Nội",
    welcomeTime: "11:00",
    note: "Nhập tiệc lúc 11:30 · Chủ Nhật, 29.11.2026"
  },

  timeline: [
    { time: "11:00", title: "Đón khách", desc: "Chụp ảnh lưu niệm cùng cô dâu chú rể" },
    { time: "11:30", title: "Nhập tiệc", desc: "Khai tiệc chung vui cùng hai gia đình" }
  ],

  dressCode: {
    text:
      "Chúng tôi sẽ rất vui nếu Quý khách lựa chọn trang phục " +
      "với tông màu hài hoà cùng không gian tiệc cưới:",
    palette: [
      { color: "#D6B994", name: "Be" },
      { color: "#FFFFFF", name: "Trắng" },
      { color: "#7996C4", name: "Xanh dương" },
      { color: "#DFA6B5", name: "Hồng" },
      { color: "#8A6BA8", name: "Tím" }
    ]
  },

  gift: {
    text:
      "Sự hiện diện của Quý khách là món quà ý nghĩa nhất đối với chúng tôi. " +
      "Nếu Quý khách muốn gửi lời chúc phúc từ xa, xin vui lòng quét mã QR dưới đây.",
    qrImage: "assets/images/qr-code.jpg"
  },

  rsvp: {
    text:
      "Quý khách vui lòng điền thông tin bên dưới để chúng tôi " +
      "chuẩn bị đón tiếp chu đáo nhất."
  },

  closing: "Rất mong được đón tiếp\nQuý khách trong ngày vui!",

  gallery: {
    spreads: true,                    // hiện từng trang photobook (nền trong suốt, hoà vào nền thiệp)
    feature: null,
    initialCount: 11,                 // số trang hiện trước khi bấm "Xem thêm"
    photos: [
      "spread-1.webp", "spread-2.webp", "spread-3.webp", "spread-4.webp",
      "spread-5.webp", "spread-6.webp", "spread-7.webp", "spread-8.webp",
      "spread-9.webp", "spread-10.webp", "spread-11.webp"
    ]
  }
};
