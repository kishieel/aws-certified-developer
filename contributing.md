# Contributing

This repository is open to contributions from the community. We encourage contributors to add subdirectories within the root directory corresponding to the AWS service they are working on. Each subdirectory should include a `readme.md` file detailing the goals and resources used for the examples provided. Preferred methods for configuring resources include using Terraform, CloudFormation, or shell scripts, ensuring that environments can be easily reproduced by other users.

## How to Contribute

1. Create a subdirectory in the root directory of the service you are working with. For example, if you want to present some features of S3, you might create a directory called `s3` in the `storage` directory. For reference how AWS resources are organized, check this PowerPoint presentation: [AWS Architecture Icons](.docs/AWS-Architecture-Icons_06072024.pptx) and current directory structure.

2. In your new subdirectory, add files related to your example as well as a `readme.md` file that describes the goals of your example, used resources, and any other relevant information. Please ensure that your examples are well-documented and easy to understand. If you are using a specific programming language, please include the necessary dependencies and installation instructions.

4. Configure your resources using Terraform, CloudFormation, or shell scripts. Please ensure your configurations are written in a way that allows other users to easily reproduce your environment.

5. Contributions should be made in the form of pull requests. Please ensure that your code is well-documented and easy to understand.
