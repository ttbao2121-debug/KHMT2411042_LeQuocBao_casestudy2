const errorMiddleware = (err, req, res, next) => {
  console.error('[Backend System Error]:', err.message);
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;

  // Lỗi Mongoose CastError (ID không hợp lệ) -> Ẩn thông tin nhạy cảm của CSDL
  if (err.name === 'CastError') {
    return res.status(400).json({ message: 'Định dạng ID dữ liệu không hợp lệ' });
  }

  // Lỗi Mongoose ValidationError -> Chuẩn hóa thông báo lỗi dữ liệu
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((val) => val.message);
    return res.status(400).json({ message: messages.join(', ') });
  }

  // Phản hồi lỗi an toàn, không tiết lộ stack trace nhạy cảm
  res.status(statusCode).json({
    message: err.message || 'Đã xảy ra lỗi máy chủ nội bộ. Vui lòng thử lại sau.',
    stack: process.env.NODE_ENV === 'production' ? null : undefined,
  });
};

module.exports = errorMiddleware;
