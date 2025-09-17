# Genome and transcriptome assembly
### How to use this repo?
Scripts are located in `/code`.
You should first modify `/code/00_setup.sh` file that sets env variables that all the rest of scripts use. That way you can have one set of variables that you reuse.
You should run the scripts via `run.sh` script, in a following way:
```bash
./run.sh code/01_qc.sh
```
Using `run.sh` allows for reusing variables from `00_setup.sh` and dispatching logs in a nicer way.

