import sys
from docling.document_converter import DocumentConverter
import os

print("TRANSFORMERS_CACHE:", os.environ.get("TRANSFORMERS_CACHE"))
print("TORCH_HOME:", os.environ.get("TORCH_HOME"))

# Rest of your script

# Get the source from command-line arguments or use default
if len(sys.argv) > 1:
    source = sys.argv[1]
else:
    source = "https://arxiv.org/pdf/2408.09869"  # Default source


cache_dir = os.environ.get("TRANSFORMERS_CACHE", "/app/cache")
torch_home = os.environ.get("TORCH_HOME", "/app/torch_home")

# Pass cache directories to the DocumentConverter or underlying models
converter = DocumentConverter(
    transformers_cache_dir=cache_dir, torch_cache_dir=torch_home
)


# converter = DocumentConverter()
result = converter.convert(source)
print(result.document.export_to_markdown())
