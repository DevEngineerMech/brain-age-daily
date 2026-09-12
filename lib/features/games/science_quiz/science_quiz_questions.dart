class ScienceQuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  const ScienceQuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

class ScienceQuizQuestions {
  static final List<ScienceQuizQuestion> all = _buildAll();

  static List<ScienceQuizQuestion> _buildAll() {
    const List<ScienceQuizQuestion> base = <ScienceQuizQuestion>[
      ScienceQuizQuestion(
        question: 'What planet is known as the Red Planet?',
        options: ['Mars', 'Venus', 'Jupiter', 'Mercury'],
        answer: 'Mars',
      ),
      ScienceQuizQuestion(
        question: 'What is the boiling point of water in Celsius?',
        options: ['100', '0', '50', '90'],
        answer: '100',
      ),
      ScienceQuizQuestion(
        question: 'What gas do plants absorb from the air?',
        options: ['Carbon Dioxide', 'Oxygen', 'Nitrogen', 'Hydrogen'],
        answer: 'Carbon Dioxide',
      ),
      ScienceQuizQuestion(
        question: 'What force keeps us on the ground?',
        options: ['Gravity', 'Magnetism', 'Friction', 'Pressure'],
        answer: 'Gravity',
      ),
      ScienceQuizQuestion(
        question: 'How many planets are in the solar system?',
        options: ['8', '7', '9', '10'],
        answer: '8',
      ),
      ScienceQuizQuestion(
        question: 'What state of matter is ice?',
        options: ['Solid', 'Liquid', 'Gas', 'Plasma'],
        answer: 'Solid',
      ),
      ScienceQuizQuestion(
        question: 'What state of matter is steam?',
        options: ['Gas', 'Liquid', 'Solid', 'Crystal'],
        answer: 'Gas',
      ),
      ScienceQuizQuestion(
        question: 'What is H2O commonly called?',
        options: ['Water', 'Oxygen', 'Hydrogen', 'Salt'],
        answer: 'Water',
      ),
      ScienceQuizQuestion(
        question: 'Which planet is the largest in the solar system?',
        options: ['Jupiter', 'Mars', 'Earth', 'Venus'],
        answer: 'Jupiter',
      ),
      ScienceQuizQuestion(
        question: 'Which star is closest to Earth?',
        options: ['Sun', 'Sirius', 'Polaris', 'Vega'],
        answer: 'Sun',
      ),
      ScienceQuizQuestion(
        question: 'What do magnets attract?',
        options: ['Metal', 'Plastic', 'Glass', 'Paper'],
        answer: 'Metal',
      ),
      ScienceQuizQuestion(
        question: 'What type of energy comes from the Sun?',
        options: ['Solar', 'Sound', 'Chemical', 'Nuclear'],
        answer: 'Solar',
      ),
      ScienceQuizQuestion(
        question: 'What tool is used to look at stars and planets?',
        options: ['Telescope', 'Microscope', 'Thermometer', 'Barometer'],
        answer: 'Telescope',
      ),
      ScienceQuizQuestion(
        question: 'What do you call molten rock that comes out of a volcano?',
        options: ['Lava', 'Steam', 'Mud', 'Ash'],
        answer: 'Lava',
      ),
      ScienceQuizQuestion(
        question: 'What is the freezing point of water in Celsius?',
        options: ['0', '10', '32', '100'],
        answer: '0',
      ),
      ScienceQuizQuestion(
        question: 'Which simple machine has a wheel with a rope?',
        options: ['Pulley', 'Lever', 'Wedge', 'Ramp'],
        answer: 'Pulley',
      ),
      ScienceQuizQuestion(
        question: 'What gas do humans need to breathe to live?',
        options: ['Oxygen', 'Carbon Dioxide', 'Nitrogen', 'Helium'],
        answer: 'Oxygen',
      ),
      ScienceQuizQuestion(
        question: 'What do bees collect from flowers?',
        options: ['Nectar', 'Steam', 'Pebbles', 'Dust'],
        answer: 'Nectar',
      ),
      ScienceQuizQuestion(
        question: 'What do we call a change from liquid to gas?',
        options: ['Evaporation', 'Freezing', 'Condensation', 'Melting'],
        answer: 'Evaporation',
      ),
      ScienceQuizQuestion(
        question: 'What do we call a change from gas to liquid?',
        options: ['Condensation', 'Evaporation', 'Freezing', 'Boiling'],
        answer: 'Condensation',
      ),
      ScienceQuizQuestion(
        question: 'What layer helps protect Earth from harmful UV rays?',
        options: ['Ozone', 'Cloud', 'Magma', 'Core'],
        answer: 'Ozone',
      ),
      ScienceQuizQuestion(
        question: 'What do we call animals that eat only plants?',
        options: ['Herbivores', 'Carnivores', 'Omnivores', 'Predators'],
        answer: 'Herbivores',
      ),
      ScienceQuizQuestion(
        question: 'What do we call animals that eat only meat?',
        options: ['Carnivores', 'Herbivores', 'Omnivores', 'Insects'],
        answer: 'Carnivores',
      ),
      ScienceQuizQuestion(
        question: 'What do we call animals that eat both plants and meat?',
        options: ['Omnivores', 'Herbivores', 'Carnivores', 'Scavengers'],
        answer: 'Omnivores',
      ),
      ScienceQuizQuestion(
        question: 'What part of a plant absorbs water from the soil?',
        options: ['Roots', 'Leaves', 'Flowers', 'Seeds'],
        answer: 'Roots',
      ),
      ScienceQuizQuestion(
        question: 'What part of the body helps you breathe?',
        options: ['Lungs', 'Kidneys', 'Bones', 'Muscles'],
        answer: 'Lungs',
      ),
      ScienceQuizQuestion(
        question: 'What organ pumps blood around the body?',
        options: ['Heart', 'Stomach', 'Liver', 'Brain'],
        answer: 'Heart',
      ),
      ScienceQuizQuestion(
        question: 'What do we call a scientist who studies weather?',
        options: ['Meteorologist', 'Biologist', 'Chemist', 'Astronomer'],
        answer: 'Meteorologist',
      ),
      ScienceQuizQuestion(
        question: 'What is measured with a thermometer?',
        options: ['Temperature', 'Speed', 'Distance', 'Weight'],
        answer: 'Temperature',
      ),
      ScienceQuizQuestion(
        question: 'What planet do we live on?',
        options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
        answer: 'Earth',
      ),
    ];

    final List<ScienceQuizQuestion> all = <ScienceQuizQuestion>[];
    for (int i = 0; i < 4; i++) {
      all.addAll(base.map((q) {
        final List<String> rotated = List<String>.generate(
          q.options.length,
          (index) => q.options[(index + i) % q.options.length],
        );
        return ScienceQuizQuestion(
          question: q.question,
          options: rotated,
          answer: q.answer,
        );
      }));
    }
    return all;
  }
}