const User = require('../models/User');

exports.searchUsers = async (req, res, next) => {
  try {
    const query = req.query.q || '';
    const regex = new RegExp(query, 'i');
    const users = await User.find({
      $or: [{ fullName: regex }, { email: regex }],
    }).select('-passwordHash');
    res.json(users);
  } catch (error) {
    next(error);
  }
};

exports.getUserById = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id).select('-passwordHash');
    if (!user) return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    res.json(user);
  } catch (error) {
    next(error);
  }
};
