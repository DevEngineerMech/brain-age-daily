class BiologyQuizQuestion {
  final String question;
  final List<String> options;
  final String answer;

  const BiologyQuizQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });
}

class BiologyQuizQuestions {
  static final List<BiologyQuizQuestion> all = _buildAll();

  static List<BiologyQuizQuestion> _buildAll() {
    const List<BiologyQuizQuestion> base = <BiologyQuizQuestion>[
      BiologyQuizQuestion(
        question: 'What part of the cell contains DNA?',
        options: ['Nucleus', 'Membrane', 'Ribosome', 'Cytoplasm'],
        answer: 'Nucleus',
      ),
      BiologyQuizQuestion(
        question: 'Which organ pumps blood around the body?',
        options: ['Heart', 'Liver', 'Kidney', 'Lung'],
        answer: 'Heart',
      ),
      BiologyQuizQuestion(
        question: 'Which gas do humans breathe in?',
        options: ['Oxygen', 'Carbon Dioxide', 'Helium', 'Hydrogen'],
        answer: 'Oxygen',
      ),
      BiologyQuizQuestion(
        question: 'Which part of a plant absorbs water?',
        options: ['Root', 'Leaf', 'Flower', 'Stem'],
        answer: 'Root',
      ),
      BiologyQuizQuestion(
        question: 'Which blood cells help fight infection?',
        options: [
          'White Blood Cells',
          'Red Blood Cells',
          'Platelets',
          'Skin Cells'
        ],
        answer: 'White Blood Cells',
      ),
      BiologyQuizQuestion(
        question: 'What pigment makes leaves green?',
        options: ['Chlorophyll', 'Melanin', 'Keratin', 'Calcium'],
        answer: 'Chlorophyll',
      ),
      BiologyQuizQuestion(
        question: 'What do plants use to make food?',
        options: ['Sunlight', 'Sand', 'Moonlight', 'Smoke'],
        answer: 'Sunlight',
      ),
      BiologyQuizQuestion(
        question: 'What is the largest organ in the human body?',
        options: ['Skin', 'Heart', 'Brain', 'Lung'],
        answer: 'Skin',
      ),
      BiologyQuizQuestion(
        question: 'How many lungs does a human usually have?',
        options: ['2', '1', '3', '4'],
        answer: '2',
      ),
      BiologyQuizQuestion(
        question: 'Which organ helps us think?',
        options: ['Brain', 'Heart', 'Stomach', 'Kidney'],
        answer: 'Brain',
      ),
      BiologyQuizQuestion(
        question: 'Which organ helps digest food?',
        options: ['Stomach', 'Liver', 'Brain', 'Lung'],
        answer: 'Stomach',
      ),
      BiologyQuizQuestion(
        question: 'Which part of the skeleton protects the brain?',
        options: ['Skull', 'Ribs', 'Spine', 'Pelvis'],
        answer: 'Skull',
      ),
      BiologyQuizQuestion(
        question: 'Which body part contains the femur?',
        options: ['Leg', 'Arm', 'Head', 'Hand'],
        answer: 'Leg',
      ),
      BiologyQuizQuestion(
        question: 'Which organ cleans blood and makes urine?',
        options: ['Kidney', 'Heart', 'Lung', 'Pancreas'],
        answer: 'Kidney',
      ),
      BiologyQuizQuestion(
        question: 'What carries oxygen around the body?',
        options: [
          'Red Blood Cells',
          'White Blood Cells',
          'Platelets',
          'Nerves'
        ],
        answer: 'Red Blood Cells',
      ),
      BiologyQuizQuestion(
        question: 'What do we call young frogs?',
        options: ['Tadpoles', 'Larvae', 'Puppies', 'Chicks'],
        answer: 'Tadpoles',
      ),
      BiologyQuizQuestion(
        question: 'Which body system includes bones?',
        options: [
          'Skeletal System',
          'Digestive System',
          'Respiratory System',
          'Circulatory System'
        ],
        answer: 'Skeletal System',
      ),
      BiologyQuizQuestion(
        question: 'Which body system includes muscles?',
        options: [
          'Muscular System',
          'Nervous System',
          'Skeletal System',
          'Digestive System'
        ],
        answer: 'Muscular System',
      ),
      BiologyQuizQuestion(
        question: 'What do herbivores mainly eat?',
        options: ['Plants', 'Meat', 'Insects', 'Fish'],
        answer: 'Plants',
      ),
      BiologyQuizQuestion(
        question: 'What do carnivores mainly eat?',
        options: ['Meat', 'Plants', 'Fruit', 'Leaves'],
        answer: 'Meat',
      ),
      BiologyQuizQuestion(
        question: 'What do omnivores eat?',
        options: ['Plants and Meat', 'Only Plants', 'Only Meat', 'Only Seeds'],
        answer: 'Plants and Meat',
      ),
      BiologyQuizQuestion(
        question: 'What part of a flower becomes fruit?',
        options: ['Ovary', 'Petal', 'Stem', 'Root'],
        answer: 'Ovary',
      ),
      BiologyQuizQuestion(
        question: 'What do insects use to smell?',
        options: ['Antennae', 'Wings', 'Claws', 'Teeth'],
        answer: 'Antennae',
      ),
      BiologyQuizQuestion(
        question: 'What type of animal feeds milk to its young?',
        options: ['Mammal', 'Fish', 'Bird', 'Reptile'],
        answer: 'Mammal',
      ),
      BiologyQuizQuestion(
        question: 'Which organ is used for breathing?',
        options: ['Lungs', 'Heart', 'Liver', 'Stomach'],
        answer: 'Lungs',
      ),
      BiologyQuizQuestion(
        question: 'What covers and protects the body?',
        options: ['Skin', 'Bone', 'Hair', 'Blood'],
        answer: 'Skin',
      ),
      BiologyQuizQuestion(
        question: 'What organ stores bile?',
        options: ['Gallbladder', 'Lung', 'Heart', 'Bladder'],
        answer: 'Gallbladder',
      ),
      BiologyQuizQuestion(
        question: 'What structure anchors a tooth in the jaw?',
        options: ['Root', 'Crown', 'Enamel', 'Gum'],
        answer: 'Root',
      ),
      BiologyQuizQuestion(
        question: 'What body fluid carries nutrients?',
        options: ['Blood', 'Air', 'Saliva', 'Sweat'],
        answer: 'Blood',
      ),
      BiologyQuizQuestion(
        question: 'What do we call animals active in the daytime?',
        options: ['Diurnal', 'Nocturnal', 'Dormant', 'Aquatic'],
        answer: 'Diurnal',
      ),
    ];

    final List<BiologyQuizQuestion> all = <BiologyQuizQuestion>[];
    for (int i = 0; i < 4; i++) {
      all.addAll(base.map((q) {
        final List<String> rotated = List<String>.generate(
          q.options.length,
          (index) => q.options[(index + i) % q.options.length],
        );
        return BiologyQuizQuestion(
          question: q.question,
          options: rotated,
          answer: q.answer,
        );
      }));
    }
    return all;
  }
}