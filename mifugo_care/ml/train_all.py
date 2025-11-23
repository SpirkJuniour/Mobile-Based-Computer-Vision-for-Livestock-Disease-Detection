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


def train_yolo_detection(data_dir: Path, model_size: str = "yolo11m.pt", epochs: int = 20, batch: int = 32):
	"""
	Train a YOLOv11 detection model on a dataset that contains a Roboflow-style data.yaml.
	OPTIMIZED FOR 99-100% ACCURACY: Using medium model, lower LR, high patience, strong augmentation.
	Auto-optimizes for GPU or CPU.
	"""
	data_yaml = data_dir / "data.yaml"
	if not data_yaml.exists():
		raise FileNotFoundError(f"data.yaml not found in {data_dir}")

	run_name = f"{data_dir.name}_{model_size}_{timestamp()}"
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
	print(f"Using device: {device} - TARGETING 100% ACCURACY")
	
	# Optimize batch size and settings based on device
	if device == "cuda":
		actual_batch = min(batch, 4)  # GPU: reduced to 4 to avoid paging file issues
		actual_workers = 2  # Reduced workers to save memory
		actual_cache = False  # Disable cache to save memory
		actual_amp = True
		if torch.cuda.is_available():
			torch.cuda.empty_cache()
	else:
		actual_batch = min(batch, 8)  # CPU: use up to 8
		actual_workers = 4
		actual_cache = False
		actual_amp = False
		print(f"CPU mode: batch={actual_batch}, workers={actual_workers}")
	
	model = YOLO(model_size)
	results = model.train(
		data=str(data_yaml),
		epochs=epochs,
		imgsz=640,
		batch=actual_batch,
		patience=20,  # Early stopping: stops if no improvement for 20 epochs
		project=str(RUNS_DIR / "detect"),
		name=run_name,
		pretrained=True,
		optimizer="AdamW",
		device=device,
		close_mosaic=10,
		cos_lr=True,
		lr0=0.001,  # Lower LR for fine-tuning to 100%
		lrf=0.01,
		momentum=0.937,
		weight_decay=0.0005,
		warmup_epochs=3.0,
		warmup_momentum=0.8,
		warmup_bias_lr=0.1,
		box=7.5,
		cls=0.5,
		dfl=1.5,
		perspective=0.0005,
		hsv_h=0.015,
		hsv_s=0.7,
		hsv_v=0.4,
		degrees=0.0,
		translate=0.1,
		scale=0.5,
		shear=0.0,
		flipud=0.0,
		fliplr=0.5,
		mixup=0.1,
		mosaic=1.0,
		copy_paste=0.1,
		cache=actual_cache,
		workers=actual_workers,
		amp=actual_amp,
		half=False,
		plots=True,  # Enable plots to monitor accuracy progress
		verbose=True,
		save=True,
		save_period=10,  # Save checkpoint every 10 epochs
	)
	# Export to ONNX for Flutter integration
	try:
		best_model_path = Path(results.save_dir) / "weights" / "best.pt"
		if best_model_path.exists():
			export_model = YOLO(str(best_model_path))
			export_model.export(format="onnx", imgsz=640, simplify=True)
			print(f"Exported ONNX model: {best_model_path.parent / 'best.onnx'}")
	except Exception as e:
		print(f"Warning: Could not export ONNX: {e}")
	return results


def train_classification_imagenet(
	data_root: Path,
	model_size: str = "yolov8m-cls.pt",
	epochs: int = 20,
	batch: int = 64,
):
	"""
	Train a classification model using Ultralytics on ImageNet-style directories.
	OPTIMIZED FOR 99-100% ACCURACY: Using medium model, lower LR, high patience, strong augmentation.
	Auto-optimizes for GPU or CPU.
	"""
	# Ultralytics classification uses YOLO(..., task='classify') behind the scenes when loading a cls model
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
	print(f"Using device: {device} - TARGETING 100% ACCURACY")
	
	# Optimize batch size and settings based on device
	if device == "cuda":
		actual_batch = min(batch, 8)  # GPU: reduced to 8 to avoid paging file issues
		actual_workers = 2  # Reduced workers to save memory
		actual_amp = True
		if torch.cuda.is_available():
			torch.cuda.empty_cache()
	else:
		actual_batch = min(batch, 16)  # CPU: use up to 16
		actual_workers = 4
		actual_amp = False
		print(f"CPU mode: batch={actual_batch}, workers={actual_workers}")
	
	results = model.train(
		data=str(data_root),
		epochs=epochs,
		batch=actual_batch,
		imgsz=224,
		lr0=0.001,  # Lower LR for fine-tuning to 100%
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
		patience=20,  # Early stopping: stops if no improvement for 20 epochs
		project=str(RUNS_DIR / "classify"),
		name=run_name,
		device=device,
		workers=actual_workers,
		amp=actual_amp,
		plots=True,  # Enable plots to monitor accuracy progress
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
	# Detection datasets with data.yaml
	detection_sets = [
		DATASETS / "animal_pathologies.v2i.yolov11",
		DATASETS / "cattle.v1i.yolov11",
		DATASETS / "Cow.v1i.yolov11",
	]

	# Classification dataset (ImageNet-style)
	classification_set = DATASETS / "cattle diseases.v2i.multiclass"

	print("=== Training: YOLOv11 Detection ===")
	print(f"CUDA Available: {torch.cuda.is_available()}")
	if torch.cuda.is_available():
		print(f"GPU: {torch.cuda.get_device_name(0)}")
	
	for dset in detection_sets:
		if dset.exists():
			print(f"Training detection on: {dset}")
			try:
				# Auto-adjust batch based on device (reduced for memory)
				initial_batch = 4 if torch.cuda.is_available() else 4
				train_yolo_detection(dset, model_size="yolo11m.pt", epochs=20, batch=initial_batch)
			except Exception as e:
				print(f"[WARN] Skipping {dset.name} due to error: {e}")
		else:
			print(f"[WARN] Dataset not found: {dset}")

	print("=== Training: Classification (Cattle Diseases) ===")
	if classification_set.exists():
		try:
			# Auto-adjust batch based on device (reduced for memory)
			initial_batch = 8 if torch.cuda.is_available() else 8
			train_classification_imagenet(classification_set, model_size="yolov8m-cls.pt", epochs=20, batch=initial_batch)
		except Exception as e:
			print(f"[WARN] Skipping classification due to error: {e}")
	else:
		print(f"[WARN] Classification dataset not found: {classification_set}")

	print("All training tasks attempted. Check runs in:", RUNS_DIR)


if __name__ == "__main__":
	main()

