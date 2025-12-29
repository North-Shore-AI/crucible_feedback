# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2025-12-26

### Added
- Conformance tests for all feedback stages
- README documentation for stage contracts

### Stages
- ExportFeedback - Export feedback data in JSONL, Parquet, or CSV format
- CheckTriggers - Evaluate retraining triggers (drift, accuracy, volume, feedback)

### Changed
- Updated crucible_framework dependency to ~> 0.5.0 for describe/1 contract

## [0.1.0] - 2025-12-25

### Added

- Initial release
- Feedback collection and storage
- Drift detection with Nx/Scholar
- Active learning integration
- Crucible Framework integration
