import importlib
import sys

# Mapping of common name to import name
libs = {
    'math': 'math',
    'random': 'random',
    'itertools': 'itertools',
    'collections': 'collections',
    'operator': 'operator',
    'typing': 'typing',
    'torch': 'torch',
    'scikit-learn': 'sklearn',
    'xgboost': 'xgboost',
    'catboost': 'catboost',
    'transformers': 'transformers',
    'spacy': 'spacy',
    'nltk': 'nltk',
    'gensim': 'gensim',
    'fasttext': 'fasttext',
    'lightgbm': 'lightgbm',
    'pandas': 'pandas',
    'numpy': 'numpy',
    'scipy': 'scipy',
    'csv': 'csv',
    'json': 'json',
    'pickle': 'pickle',
    'zipfile': 'zipfile',
    'glob': 'glob',
    'opencv-python': 'cv2',
    'Pillow': 'PIL',
    'torchvision': 'torchvision',
    'scikit-image': 'skimage',
    'matplotlib': 'matplotlib',
    'seaborn': 'seaborn',
    'plotly': 'plotly',
    'autoviz': 'autoviz',
    'joblib': 'joblib',
    'datasets': 'datasets',
    'evaluate': 'evaluate',
    'os': 'os',
    'sys': 'sys',
    're': 're',
    'time': 'time',
    'pdb': 'pdb',
    'pytorch-lightning': 'pytorch_lightning',
    'tensorboard': 'tensorboard',
    'tqdm': 'tqdm',
    'torchmetrics': 'torchmetrics'
}

print(f"Python Version: {sys.version}")
print("-" * 40)

failed = []
for name, module_name in libs.items():
    try:
        mod = importlib.import_module(module_name)
        version = getattr(mod, '__version__', 'N/A')
        print(f"✅ {name:<20} ({module_name}): {version}")
    except Exception as e:
        print(f"❌ {name:<20} ({module_name}): FAILED - {e}")
        failed.append(name)

print("-" * 40)
if not failed:
    print("SUCCESS: All imports working!")
else:
    print(f"FAILURE: {len(failed)} libraries failed to import: {failed}")

# Verificari NLP offline: NLTK, spaCy, gensim, transformers, TF-IDF, fasttext
print("=" * 70)
print("NLP OFFLINE CHECKS")
print("=" * 70)

nlp_failed = []

def check_step(name, fn):
    print(f"\n[CHECK] {name}")
    try:
        fn()
        print(f"✅ {name}")
    except Exception as e:
        print(f"❌ {name} -> {e}")
        traceback.print_exc(limit=1)
        nlp_failed.append((name, str(e)))


def check_nltk():
    import nltk

    required = [
        ("tokenizers/punkt", "punkt"),
        ("corpora/stopwords", "stopwords"),
        ("corpora/wordnet", "wordnet"),
        ("corpora/omw-1.4", "omw-1.4"),
        ("taggers/averaged_perceptron_tagger", "averaged_perceptron_tagger"),
        ("chunkers/maxent_ne_chunker", "maxent_ne_chunker"),
        ("corpora/words", "words"),
    ]

    missing = []
    for path, label in required:
        try:
            nltk.data.find(path)
        except LookupError:
            missing.append(label)

    if missing:
        raise RuntimeError(f"Missing NLTK resources: {missing}")

    from nltk.tokenize import word_tokenize
    from nltk.corpus import stopwords, wordnet
    from nltk.stem import WordNetLemmatizer
    from nltk import pos_tag, ne_chunk

    text = "Apple is buying a startup in London."
    tokens = word_tokenize(text)
    tags = pos_tag(tokens)
    tree = ne_chunk(tags)
    sw = stopwords.words("english")
    lemma = WordNetLemmatizer().lemmatize("running", pos="v")
    syns = wordnet.synsets("dog")

    print("Tokens:", tokens)
    print("Stopwords sample:", sw[:5])
    print("Lemma(running):", lemma)
    print("Synsets(dog):", len(syns))
    print("NER tree built:", tree is not None)


def check_spacy():
    import spacy

    try:
        nlp = spacy.load("en_core_web_sm")
    except Exception as e:
        raise RuntimeError("spaCy model 'en_core_web_sm' not available") from e

    doc = nlp("Apple is buying a startup in London.")
    print("Tokens:", [t.text for t in doc])
    print("Lemmas:", [t.lemma_ for t in doc])
    print("Entities:", [(ent.text, ent.label_) for ent in doc.ents])


def check_gensim():
    import gensim.downloader as api

    # trebuie sa fie deja in cache local daca ai facut pregatirea offline
    model = api.load("glove-wiki-gigaword-50")
    vec = model["computer"]
    sims = model.most_similar("computer", topn=3)

    print("Vector size:", len(vec))
    print("Most similar to 'computer':", sims)


def check_transformers():
    from transformers import AutoTokenizer, AutoModel

    model_name = "distilbert-base-uncased"

    try:
        tokenizer = AutoTokenizer.from_pretrained(model_name, local_files_only=True)
        model = AutoModel.from_pretrained(model_name, local_files_only=True)
    except Exception as e:
        raise RuntimeError(
            f"Transformers model/tokenizer '{model_name}' not found locally"
        ) from e

    inputs = tokenizer("This is a test sentence.", return_tensors="pt")
    outputs = model(**inputs)

    print("Input ids shape:", tuple(inputs["input_ids"].shape))
    print("Last hidden state shape:", tuple(outputs.last_hidden_state.shape))


def check_tfidf():
    from sklearn.feature_extraction.text import CountVectorizer, TfidfVectorizer

    texts = [
        "machine learning is fun",
        "natural language processing is useful",
        "tf idf is a classic text representation",
    ]

    bow = CountVectorizer(ngram_range=(1, 2))
    X_bow = bow.fit_transform(texts)

    tfidf = TfidfVectorizer(stop_words="english", ngram_range=(1, 2))
    X_tfidf = tfidf.fit_transform(texts)

    print("BoW shape:", X_bow.shape)
    print("TF-IDF shape:", X_tfidf.shape)
    print("TF-IDF features sample:", tfidf.get_feature_names_out()[:10].tolist())


def check_fasttext():
    import tempfile
    import fasttext

    train_data = """__label__tech machine learning is useful
__label__tech transformers process text
__label__sport football is a popular sport
__label__sport basketball is played on a court
"""

    with tempfile.NamedTemporaryFile("w", delete=False, suffix=".txt", encoding="utf-8") as f:
        f.write(train_data)
        train_path = f.name

    model = fasttext.train_supervised(train_path, epoch=5, lr=1.0, wordNgrams=2, verbose=0)
    labels, probs = model.predict("machine learning for text")
    print("Prediction:", labels, probs)

    try:
        os.remove(train_path)
    except OSError:
        pass


check_step("NLTK resources + tokenization/tagging/lemmatization", check_nltk)
check_step("spaCy English model", check_spacy)
check_step("gensim embeddings cache", check_gensim)
check_step("transformers local model/tokenizer", check_transformers)
check_step("scikit-learn BoW / TF-IDF", check_tfidf)
check_step("fasttext local training", check_fasttext)

print("\n" + "=" * 70)
if not nlp_failed:
    print("SUCCESS: All NLP checks passed.")
else:
    print(f"FAILURE: {len(nlp_failed)} NLP checks failed.")
    for name, err in nlp_failed:
        print(f" - {name}: {err}")
print("=" * 70)
