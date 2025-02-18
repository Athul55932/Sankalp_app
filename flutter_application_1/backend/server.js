const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid'); // Import uuid package

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(cors({ origin: 'http://localhost:8080' })); // Replace with your frontend origin

mongoose
  .connect('mongodb://localhost:27017/sankalp', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log('MongoDB connected'))
  .catch((err) => console.log(err));

mongoose.connection.on('error', (err) => {
  console.error('Database connection error:', err);
});



const counterSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  sequenceValue: { type: Number, required: true },
});

const Counter = mongoose.model('Counter', counterSchema);




const getNextSequenceValue = async (sequenceName) => {
  try {
      const counter = await Counter.findOneAndUpdate(
          { name: sequenceName },
          { $inc: { sequenceValue: 1 } },
          { new: true } // Returns the updated document
      );

      if (!counter) {
          throw new Error(`Counter for ${sequenceName} does not exist.`);
      }

      return counter.sequenceValue;
  } catch (err) {
      console.error('Error generating sequence value:', err);
      throw err;
  }
};

module.exports = getNextSequenceValue;


module.exports = Counter;
// const Certificate = require('./models/Certificate'); // Import the Certificate model
const certificateSchema = new mongoose.Schema({
  certificateId: { type: String, required: true, unique: true },
  certificateType: { type: String, required: true },
  fields: { type: Map, of: String }, // Flexible field storage
});

const Certificate = mongoose.model('Certificate', certificateSchema);


app.use(express.json());



// Connect to MongoDB (make sure you have MongoDB running)


// Define the schema for certificates
const Schema = mongoose.Schema;

app.post('/fetchCertificates', async (req, res) => {
  const { certificateType } = req.body;

  try {
    const certificates = await Certificate.find({ certificateType });
    res.status(200).json(certificates);
  } catch (error) {
    res.status(500).json({ message: 'Error fetching certificates', error });
  }
});


app.post('/save-certificate', async (req, res) => {
  const { certificateType, fields } = req.body;

  try {
    const nextId = await getNextSequenceValue('certificateId');
    const certificateId = `CERT-${nextId}`; // Example format: CERT-1, CERT-2

    const newCertificate = new Certificate({
        certificateId: certificateId,
        certificateType: req.body.certificateType,
        fields: req.body.fields,
    });

    const savedCertificate = await newCertificate.save();
    res.status(201).json(savedCertificate);
} catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error creating certificate' });
}
});


// Start the server
app.listen(8080, () => {
  console.log('Server is running on port 8080');
});