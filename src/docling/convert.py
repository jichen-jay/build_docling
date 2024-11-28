import sys
from docling.document_converter import DocumentConverter
import os
from pathlib import Path

print("TRANSFORMERS_CACHE:", os.environ.get("TRANSFORMERS_CACHE"))
print("TORCH_HOME:", os.environ.get("TORCH_HOME"))

if len(sys.argv) > 1:
    source_arg = sys.argv[2]
    if source_arg.startswith("http"):  # Check for URL
        source = source_arg
    else:
        source = Path(source_arg).resolve()  # Create a Path object for local files

    if not source.exists():
        raise FileNotFoundError(f"File does not exist {source}")
else:
    source = "https://arxiv.org/pdf/2408.09869"  # Default URL source


cache_dir = os.environ.get("TRANSFORMERS_CACHE", "/app/cache")
torch_home = os.environ.get("TORCH_HOME", "/app/torch_home")

# Pass cache directories to the DocumentConverter or underlying models
# converter = DocumentConverter(
#     transformers_cache_dir=cache_dir, torch_cache_dir=torch_home
# )

print("source:", source)

converter = DocumentConverter()
result = converter.convert(source)
print(result.document.export_to_markdown())
