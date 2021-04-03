# helm-tests

### Run integration tests (Mac):
```sh
./kind-int-tests.sh
```

---
### Actual tests have been taken directly from Terratest examples:

https://github.com/gruntwork-io/terratest/tree/master/examples
- helm_basic_example_integration_test.go
- helm_basic_example_template_test.go

---
### Generate go.mod go.sum
```sh
cd test

go mod init github.com/drimailorr/helm-go-tests/test

go mod download github.com/gruntwork-io/terratest
```