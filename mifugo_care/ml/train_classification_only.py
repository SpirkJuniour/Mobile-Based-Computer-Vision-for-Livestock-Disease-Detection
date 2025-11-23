"""Train only the classification model."""
import os
from pathlib import Path
from datetime import datetime
from ultralytics import YOLO
import torch

ROOT = Path("D:/mifugo_care")
DATASETS = ROOT / "datasets"
RUNS_DIR = ROOT / "ml" / "runs"
RUNS_DIR.mkdir(parents=True, exist_ok=True)

def timestamp() -> str:
	"""Generate a compact timestamp string for run naming."""
	return datetime.now().strftime("%Y%m%d-%H%M%S")

def train_classification_imagenet(
	data_root: Path,
	model_size: str = "yolov8m-cls.pt",
	epochs: int = 20,
	batch: int = 8,
):
	"""
	Train a classification model using Ultralytics on ImageNet-style directories.
	"""
	model = YOLO(model_size)
	run_name = f"{data_root.name}_{model_size}_{timestamp()}"
	
	# Try GPU first, but fallback to CPU if paging file issues occur
	device = "cuda" if torch.cuda.is_available() else "cpu"
	try:
		# Test if we can actually use CUDA (may fail due to paging file)
		if device == "cuda":
			torch.cuda.empty_cache()
			# Quick test to see if CUDA works
			test_tensor = torch.zeros(1).cuda()
			del test_tensor
	except Exception as e:
		print(f"Warning: GPU unavailable ({e}), falling back to CPU")
		device = "cpu"
	print(f"Using device: {device}")
	
	# Optimize batch size and settings based on device
	if device == "cuda":
		actual_batch = min(batch, 8)  # GPU: reduced to 8 to avoid paging file issues
		actual_workers = 2  # Reduced workers to save memory
		actual_amp = True
		if torch.cuda.is_available():
			torch.cuda.empty_cache()
	else:
		actual_batch = min(batch, 8)
		actual_workers = 2
		actual_amp = False
		print(f"CPU mode: batch={actual_batch}, workers={actual_workers}")
	
	results = model.train(
		data=str(data_root),
		epochs=epochs,
		batch=actual_batch,
		imgsz=224,
		lr0=0.001,
		lrf=0.01,
		momentum=0.9,
		weight_decay=5e-4,
		warmup_epochs=3.0,
		warmup_momentum=0.8,
		warmup_bias_lr=0.1,
		label_smoothing=0.1,
		hsv_h=0.015,
		hsv_s=0.7,
		hsv_v=0.4,
		degrees=0.0,
		translate=0.1,
		scale=0.5,
		flipud=0.0,
		fliplr=0.5,
		mosaic=1.0,
		mixup=0.1,
		cos_lr=True,
		patience=20,
		project=str(RUNS_DIR / "classify"),
		name=run_name,
		device=device,
		workers=actual_workers,
		amp=actual_amp,
		plots=True,
		verbose=True,
		save=True,
		save_period=10,
	)
	
	# Export to ONNX for Flutter integration
	try:
		best_model_path = Path(results.save_dir) / "weights" / "best.pt"
		if best_model_path.exists():
			export_model = YOLO(str(best_model_path))
			export_model.export(format="onnx", imgsz=224, simplify=True)
			print(f"Exported ONNX model: {best_model_path.parent / 'best.onnx'}")
	except Exception as e:
		print(f"Warning: Could not export ONNX: {e}")
	return results

def main():
	classification_set = DATASETS / "cattle diseases.v2i.multiclass"
	
	print("=== Training: Classification (Cattle Diseases) ===")
	print(f"CUDA Available: {torch.cuda.is_available()}")
	if torch.cuda.is_available():
		print(f"GPU: {torch.cuda.get_device_name(0)}")
	
	if classification_set.exists():
		try:
			train_classification_imagenet(classification_set, model_size="yolov8m-cls.pt", epochs=20, batch=8)
			print("\n✅ Classification training completed!")
		except Exception as e:
			print(f"❌ Error during classification training: {e}")
			import traceback
			traceback.print_exc()
	else:
		print(f"❌ Classification dataset not found: {classification_set}")

if __name__ == "__main__":
	main()

