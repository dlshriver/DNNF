#!/bin/bash

n=1
timeout=3600
resv=""

mkdir -p logs
mkdir -p results

run_falsifier() {
    njobs=$1
    shift
    artifact=$1
    shift
    variant=$1
    shift
    options="-T $timeout -v -p 8"
    name=$artifact.$variant
    echo "./scripts/run_falsification.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${options} $@"
    for ((i = 1; i <= $njobs; i++)); do
        ./scripts/run_falsification.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${options} $@
    done
}

run_falsifier2() {
    njobs=$1
    shift
    artifact=$1
    shift
    variant=$1
    shift
    options="-T $timeout -v -p 8"
    name=$artifact.$variant
    echo "./scripts/run_falsification2.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${options} $@"
    for ((i = 1; i <= $njobs; i++)); do
        ./scripts/run_falsification2.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${options} $@
    done
}

run_verifier() {
    njobs=$1
    shift
    artifact=$1
    shift
    verifier=$1
    shift
    variant=$1
    shift
    options="-T $timeout -v"
    name=$artifact.$variant
    echo "./scripts/run_verification.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${verifier} ${options} $@"
    for ((i = 1; i <= $njobs; i++)); do
        ./scripts/run_verification.sh results/${name}.csv artifacts/${artifact}_benchmark/ ${verifier} ${options} $@
    done
}

# ACAS
artifact="acas"
run_falsifier $n $artifact "cleverhans_LBFGS" "--backend cleverhans.LBFGS --n_start 1 --set cleverhans.LBFGS y_target \"[[-1.0, 0.0]]\""
run_falsifier $n $artifact "cleverhans_BasicIterativeMethod" "--backend cleverhans.BasicIterativeMethod --n_start 1"
run_falsifier $n $artifact "cleverhans_FastGradientMethod" "--backend cleverhans.FastGradientMethod --n_start 1"
run_falsifier $n $artifact "cleverhans_DeepFool" "--backend cleverhans.DeepFool --set cleverhans.DeepFool nb_candidate 2 --n_start 1"
run_falsifier $n $artifact "cleverhans_ProjectedGradientDescent" "--backend cleverhans.ProjectedGradientDescent"

run_verifier $n $artifact "neurify" "neurify" "--neurify.max_thread=8"
run_verifier $n $artifact "eran" "eran" "--eran.domain=deepzono"

# Global Halfspace-Polytope Reachability
artifact="ghpr"
run_falsifier $n $artifact "cleverhans_LBFGS" "--backend cleverhans.LBFGS --n_start 1 --set cleverhans.LBFGS y_target \"[[-1.0, 0.0]]\""
run_falsifier $n $artifact "cleverhans_BasicIterativeMethod" "--backend cleverhans.BasicIterativeMethod --n_start 1"
run_falsifier $n $artifact "cleverhans_FastGradientMethod" "--backend cleverhans.FastGradientMethod --n_start 1"
run_falsifier $n $artifact "cleverhans_DeepFool" "--backend cleverhans.DeepFool --set cleverhans.DeepFool nb_candidate 2 --n_start 1"
run_falsifier $n $artifact "cleverhans_ProjectedGradientDescent" "--backend cleverhans.ProjectedGradientDescent"

run_verifier $n $artifact "neurify" "neurify" "--neurify.max_thread=8"
run_verifier $n $artifact "eran" "eran" "--eran.domain=deepzono"

# Neurify-DAVE
artifact="neurifydave"
for epsilon in 1 2 5 8 10; do
    run_falsifier $n $artifact "eps${epsilon}.cleverhans_LBFGS" "--backend cleverhans.LBFGS --n_start 1 --set cleverhans.LBFGS y_target \"[[-1.0, 0.0]]\" --prop.epsilon=${epsilon}"
    run_falsifier $n $artifact "eps${epsilon}.cleverhans_BasicIterativeMethod" "--backend cleverhans.BasicIterativeMethod --n_start 1 --prop.epsilon=${epsilon}"
    run_falsifier $n $artifact "eps${epsilon}.cleverhans_FastGradientMethod" "--backend cleverhans.FastGradientMethod --n_start 1 --prop.epsilon=${epsilon}"
    run_falsifier $n $artifact "eps${epsilon}.cleverhans_DeepFool" "--backend cleverhans.DeepFool --set cleverhans.DeepFool nb_candidate 2 --n_start 1 --prop.epsilon=${epsilon}"
    run_falsifier $n $artifact "eps${epsilon}.cleverhans_ProjectedGradientDescent" "--backend cleverhans.ProjectedGradientDescent --prop.epsilon=${epsilon}"

    run_verifier $n $artifact "neurify" "eps${epsilon}.neurify" "--neurify.max_thread=8 --prop.epsilon=${epsilon}"
    run_verifier $n $artifact "eran" "eps${epsilon}.eran" "--eran.domain=deepzono --prop.epsilon=${epsilon}"
done

# run tensorfuzz last
# ACAS
artifact="acas"
run_falsifier $n $artifact "tensorfuzz" "--backend tensorfuzz"
# Output Relational
artifact="ghpr"
run_falsifier $n $artifact "tensorfuzz" "--backend tensorfuzz"
# Neurify-DAVE
artifact="neurifydave"
for epsilon in 1 2 5 8 10; do
    run_falsifier $n $artifact "eps${epsilon}.tensorfuzz" "--backend tensorfuzz --prop.epsilon=${epsilon}"
done
