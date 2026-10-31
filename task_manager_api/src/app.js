const express = require('express');
const cors = require('cors');
const errorMiddleware = require('./middleware/errorMiddleware');

const authRoutes = require('./routes/authRoutes');
const userRoutes = require('./routes/userRoutes');
const taskRoutes = require('./routes/taskRoutes');
const assignmentRoutes = require('./routes/assignmentRoutes');
const taskShareRoutes = require('./routes/taskShareRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const statisticsRoutes = require('./routes/statisticsRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req, res) => {
  res.json({ message: 'TaskManager API is running...' });
});

app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/tasks', taskRoutes);
app.use('/api/assignments', assignmentRoutes);
app.use('/api/shares', taskShareRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/statistics', statisticsRoutes);

app.use(errorMiddleware);

module.exports = app;
