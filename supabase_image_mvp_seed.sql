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
    ('english', 1, 'friend', 'der Freund', 'vocab-images/friend.png', 'My friend is kind.', 'Mein Freund ist nett.', 1, 'noun'),
    ('english', 1, 'apple', 'der Apfel', 'vocab-images/apple.png', 'The apple is red.', 'Der Apfel ist rot.', 1, 'noun'),
    ('english', 1, 'car', 'das Auto', 'vocab-images/car.png', 'The car is fast.', 'Das Auto ist schnell.', 1, 'noun'),
    ('english', 1, 'cat', 'die Katze', 'vocab-images/cat.png', 'The cat is small.', 'Die Katze ist klein.', 1, 'noun'),
    ('english', 1, 'book', 'das Buch', 'vocab-images/book.png', 'I read a book.', 'Ich lese ein Buch.', 1, 'noun'),
    ('english', 1, 'ball', 'der Ball', 'vocab-images/ball.png', 'The ball is round.', 'Der Ball ist rund.', 1, 'noun'),
    ('english', 1, 'chair', 'der Stuhl', 'vocab-images/chair.png', 'The chair is wooden.', 'Der Stuhl ist aus Holz.', 1, 'noun'),
    ('english', 1, 'table', 'der Tisch', 'vocab-images/table.png', 'The table is round.', 'Der Tisch ist rund.', 1, 'noun'),
    ('english', 1, 'sun', 'die Sonne', 'vocab-images/sun.png', 'The sun is bright.', 'Die Sonne ist hell.', 1, 'noun'),
    ('english', 1, 'moon', 'der Mond', 'vocab-images/moon.png', 'The moon is in the sky.', 'Der Mond ist am Himmel.', 1, 'noun'),
    ('english', 1, 'star', 'der Stern', 'vocab-images/star.png', 'The star is yellow.', 'Der Stern ist gelb.', 1, 'noun'),
    ('english', 1, 'fish', 'der Fisch', 'vocab-images/fish.png', 'The fish is orange.', 'Der Fisch ist orange.', 1, 'noun'),
    ('english', 1, 'bird', 'der Vogel', 'vocab-images/bird.png', 'The bird is blue.', 'Der Vogel ist blau.', 1, 'noun'),
    ('english', 1, 'flower', 'die Blume', 'vocab-images/flower.png', 'The flower is pink.', 'Die Blume ist rosa.', 1, 'noun'),
    ('english', 1, 'door', 'die Tuer', 'vocab-images/door.png', 'I open the door.', 'Ich oeffne die Tuer.', 1, 'noun'),
    ('english', 1, 'window', 'das Fenster', 'vocab-images/window.png', 'The window is blue.', 'Das Fenster ist blau.', 1, 'noun')
) as v(language, unit, foreign_word, german_word, image, example, example_translation, difficulty, word_type)
where not exists (
  select 1
  from public.vocab_items i
  where i.language = v.language
    and i.foreign_word = v.foreign_word
    and i.unit = v.unit
);
