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
