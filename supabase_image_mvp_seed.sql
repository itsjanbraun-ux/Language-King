-- Language King: first picture-word MVP vocabulary.
-- Run after supabase_vocab_image_fields.sql.
-- This adds global English image vocabulary rows. For profile-specific sets,
-- import vocab-image-mvp.json in the app instead.

insert into public.vocab_items (
  language,
  unit,
  foreign_word,
  german_word,
  image,
  example,
  example_translation,
  difficulty,
  word_type
)
select v.language, v.unit, v.foreign_word, v.german_word, v.image,
       v.example, v.example_translation, v.difficulty, v.word_type
from (
  values
    ('english', 1, 'dog', 'der Hund', 'vocab-images/dog.png', 'The dog is friendly.', 'Der Hund ist freundlich.', 1, 'noun'),
    ('english', 1, 'house', 'das Haus', 'vocab-images/house.png', 'The house is small.', 'Das Haus ist klein.', 1, 'noun'),
    ('english', 1, 'goal', 'das Tor', 'vocab-images/goal.png', 'The ball is in the goal.', 'Der Ball ist im Tor.', 1, 'noun'),
    ('english', 1, 'water', 'das Wasser', 'vocab-images/water.png', 'I drink water.', 'Ich trinke Wasser.', 1, 'noun'),
    ('english', 1, 'bread', 'das Brot', 'vocab-images/bread.png', 'The bread is fresh.', 'Das Brot ist frisch.', 1, 'noun'),
    ('english', 1, 'king', 'der Koenig', 'vocab-images/king.png', 'The king has a crown.', 'Der Koenig hat eine Krone.', 1, 'noun'),
    ('english', 1, 'queen', 'die Koenigin', 'vocab-images/queen.png', 'The queen has a crown.', 'Die Koenigin hat eine Krone.', 1, 'noun'),
    ('english', 1, 'school', 'die Schule', 'vocab-images/school.png', 'We go to school.', 'Wir gehen zur Schule.', 1, 'noun'),
    ('english', 1, 'tree', 'der Baum', 'vocab-images/tree.png', 'The tree is green.', 'Der Baum ist gruen.', 1, 'noun'),
    ('english', 1, 'friend', 'der Freund', 'vocab-images/friend.png', 'My friend is kind.', 'Mein Freund ist nett.', 1, 'noun')
) as v(language, unit, foreign_word, german_word, image, example, example_translation, difficulty, word_type)
where not exists (
  select 1
  from public.vocab_items i
  where i.language = v.language
    and i.foreign_word = v.foreign_word
    and i.unit = v.unit
);
