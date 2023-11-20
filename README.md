# Fappcli
Creating ACAP applications for AXIS network cameras has never been easier! FApp is a set of tools, libraries and templates that can be used to create and build ACAP applications.

## Installation
FApp CLI is implemented in Python and can be installed with e.g. pip from our AWS pypi repository. There are no other dependencies than Python, listed Python packages, SSH, and [Docker](https://docs.docker.com/engine/install/) needed. To access the package from AWS pypi you will need to have the [AWS CLI installed](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

### Linux / MacOS
The tool can be installed using our AWS pypi. We recommend to first activate a Python environment using e.g. pyenv or Python Virtualenv since this script will install the fappcli tool in the currently used Python environment. You need a valid token to give you access. Run the following, replacing `<AWS_ACCESS_KEY_ID>` and `<AWS_SECRET_ACCESS_KEY>` with your private keys that you have received from us.
```bash
./install.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>
```

If you want to install a specific version of fappcli, you can list all versions by adding an empty string as the third argument:
```bash
./install.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> ""
```

After selecting the version you want, you can input it as the third argument, e.g., to install an unreleased development version:
```bash
./install.sh <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> "0.0.2.dev77+abcd123"
```

You can now test the command by running:
```bash
fappcli-config --help
```

Note that if you installed the command in a Python environment, the command will only exist if you have that environment activated.

### Windows cmd
The `install.bat` script can be used to install fappcli in a cmd-prompt. We recommend to first activate a Python environment using e.g. Conda since this script will install the fappcli tool in the currently used Python environment. You need a valid token to give you access. Run the following command, replacing the two keys with your private keys that you have received from us:
```cmd
.\install.bat <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY>
```

If you want to install a specific version of fappcli, you can list all versions by adding an empty string as the third argument:
```cmd
.\install.bat <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> ""
```

After selecting the version you want, you can input it as the third argument, e.g., to install an unreleased development version:
```cmd
.\install.bat <AWS_ACCESS_KEY_ID> <AWS_SECRET_ACCESS_KEY> "0.0.2.dev77+abcd123"
```

You can now test the command by running:
```cmd
fappcli-config --help
```

Note that if you installed the command in a Python environment, the command will only exist if you have that environment activated.

## Uninstallation
To uninstall, run:
```bash
pip uninstall fappcli
```

For a full clean-up, you can also remove the `.fapp` config file in the location described below.

## Configuration
The next step is to configure the FApp CLI tool. Some functionality, like building applications that do not use the FixedIT prebuilt libraries, will work without any further configuration, while other functionality such as installing applications in the camera or using our precompiled libraries will not work without more configuration. The configuration of the tool is done in a json file named `.fapp`, but the location where the tool looks for the file differs depending on the OS.

### Creating the configuration file

#### Linux
In Linux, the location of the FApp CLI file is in your home directory `~/.fapp` (i.e. `/home/<USERNAME>/.fapp`). Note that the file does not have a type suffix / file name extension.

#### Windows
In Windows, the location of the FApp CLI file is in your home folder, e.g. `C:\Users\<USERNAME>\.fapp`. Note that the file does not have a file name extension, the default in Windows is that the extension of text files defaults to `.txt` and is not shown to the user, therefore you might need to check the `Select file name extension` box in the folder's view settings.

### Adding configuration to the file
To be able to use the `libfapp` library or our prebuilt libraries when building applications, you need to specify a token in the `~/.fapp` config file. If you have AWS credentials instead of a FApp CLI token, then you can create a token by running this command and copying the output.
```bash
fappcli-config create-token --aws-access-key-id <AWS_ACCESS_KEY_ID> --aws-secret-access-key <AWS_SECRET_ACCESS_KEY>
```

Next, place the token in your `~/.fapp` config file as `secrets.default`. It should look like this:
```json
{
    "secrets": {
        "default": "<TOKEN>"
    }
}
```

To allow the tool to use cameras e.g. to install or run an application, you will need to specify the hostname/IP of the camera and the camera's architecture. There are two different ways of adding cameras, either using the `host` key which expects the IP address or domain name / URL of the camera, or the `ssh-host` that allows you to use the SSH hostname configuration from your computer. The latter option is also usable if you have SSH access to the camera (using e.g. an SSH proxy) but not HTTP(S) access. The tool will then automatically proxy all VAPIX commands over SSH. If using the `ssh-host` option and you have installed your SSH keys in the camera, then you do not need to specify the password to the camera in the configuration file.

The name of the cameras will be used when using the FApp CLI commands and can be as per your choice. To add a camera with the name `my_camera_name`, the IP address `<IP>` and the `aarch64` architecture with the username `<USERNAME>` and password `<PASSWORD>`, the `.fapp` file could look like this:
```json
{
  "cameras": {
    "my_camera_name": {
      "host": "<IP>",
      "arch": "aarch64",
      "credentials": {
        "username": "<USERNAME>",
        "password": "<PASSWORD>"
      }
    }
  }
}
```

If you want to use SSH only to access the camera, you can use the `ssh-host` option. This should be set to the IP address or the SSH hostname specified in the SSH configuration file.
```json
{
  "cameras": {
    "my_camera_name": {
      "ssh-host": "<SSH_HOST>",
      "arch": "aarch64",
      "credentials": {
        "username": "<USERNAME>",
        "password": "<PASSWORD>"
      }
    }
  }
}
```

If you are using the `ssh-host` option and want to use SSH key files instead of a password, you can omit the credentials section.

### Configuring SSH in the camera
Some commands in the FApp CLI tool use SSH. This means that you must make sure that you have SSH enabled in the camera's config. This is found either under plain configuration or under `System->Accounts` in newer firmware.

#### Setting up passwordless SSH
Passwordless SSH can be set up by installing your RSA SSH key in the camera. If this is done, and the username is configured in the SSH config file, the FApp CLI tool will be able to use the camera even if the credentials section is omited in the `.fapp` config file. Setting up passwordless camera access like this currently does not work if the camera is set to not allow SSH as the root user.

##### Linux
When using passwordless SSH, you need to specify the camera's username in your SSH config file which can be found at the `~/.ssh/config` path. This file could e.g. look like this, where `<CAMERA_IP>` is substituted:
```
Host <CAMERA_IP>
	User root
```

To configure passwordless SSH access, generate an SSH key with an empty passphrase if you don't already have one.
```
ssh-keygen
```

Then install the SSH key in the camera using the following command, where `<CAMERA_IP>` should be substituted for the camera's IP or SSH hostname.
```
ssh-copy-id <CAMERA_IP>
```

You can now try to SSH to the device by typing `ssh <CAMERA_IP>` which should open a shell in the camera without asking for password. When this is working, you can omit the `credentials` section from the camera configuration in the `.fapp` file.

##### Windows
When using passwordless SSH, you need to specify the camera's username in your SSH config file which can be found in the `<HOME_FOLDER>\.ssh\config`, e.g. `C:\Users\<USERNAME>\.ssh\config`. This file could e.g. look like this, where `<CAMERA_IP>` is substituted:
```
Host <CAMERA_IP>
	User root
```

To configure passwordless SSH access, generate an SSH key with an empty passphrase if you don't already have one.
```
ssh-keygen.exe
```

Then install the SSH key in the camera using the following command, where `<SSH_HOST>` should be substituted for the camera's IP or SSH hostname. This command only works in PowerShell, not the cmd-prompt.
```
$publicKey = Get-Content -Path "$env:USERPROFILE\.ssh\id_rsa.pub"
ssh <SSH_HOST> "echo $publicKey >> ~/.ssh/authorized_keys"
```

You can now try to SSH to the device by typing `ssh <SSH_HOST>` which should open a shell in the camera without asking for password. When this is working, you can omit the `credentials` section from the camera configuration in the `.fapp` file.

### Testing the configuration
You can verify that the FApp CLI tool has picked up your configuration by running the following command:
```
fappcli-config show
```

The output will show the total config which consists of the tool defaults plus your config file. The output could e.g. look like this:
```json
{
    "application": {},
    "template": {
        "uri": "git+ssh://git@github.com/fixedit-ai/fapp.git",
        "base_dir": "cookiecutter/"
    },
    "secrets": {
        "default": "************************************************************************************************************************************************************************************************************************************************"
    },
    "cameras": {
        "cam-a8": {
            "ssh-host": "192.168.0.195",
            "arch": "aarch64"
        },
        "cam-tpu": {
            "host": "192.168.0.182",
            "credentials": {
                "username": "root",
                "password": "****"
            },
            "arch": "aarch64"
        }
    }
}
```

To verify that the camera configuration is correct, you can use the `fappcli-deploy list` command which will test access to all your cameras. The output can e.g. look like this:
```
+---------+--------+---------------+---------------+--------------+
|  Camera | Status |   HTTP host   |    SSH host   | Architecture |
+---------+--------+---------------+---------------+--------------+
|  cam-a8 |   OK   |               | 192.168.0.195 |   aarch64    |
| cam-tpu |   OK   | 192.168.0.182 |               |   aarch64    |
+---------+--------+---------------+---------------+--------------+
```

## Usage
All commands implement a `--help` option which will print a short description of the command and all available options. The commands are grouped into different entry points, such as `fappcli-deploy` and `fappcli-build`. Each entry point has different commands such as `fappcli-deploy list` and `fappcli-deploy proxy`. To list and describe the available commands in the `fappcli-deploy` entry point, run `fappcli-deploy --help`. To list the options for a specific command, run e.g. `fappcli-deploy proxy --help`.

### The fapp-manifest.json file
The FApp CLI commands to build, install and run ACAPs have a lot of options that can be specified. Many of these options' values depend on how the ACAP code / build code is written. To avoid repeating these options every time an ACAP is built, a `fapp-manifest.json` file can be used. This is a json file that specifies default values for all the options in the `build`, `install` and `run` commands. If a `fapp-manifest.json` file exists in the directory where the command is run, it will be automatically used. If the file has another name or is located in another dir, it can be manually specified with the `--fapp-manifest <PATH>` option. This allows you to have multiple files for different build configurations, e.g. test, release and debug. The allowed values in the files are the same as for the CLI commands (show with `--help`) but with underscores (`_`) instead of dashes (`-`). Two examples can be seen below.

Content of `fapp-manifest.json`, the default configuration:
```json
{
    "build": {
        "arch": "armv7hf",
        "lib": ["libfapp", "curl", "openssl", "json-glib"],
        "sdk_name": "acap-native-sdk"
    }
}
```

Content of `fapp-manifest.debug.json`, the debug build configuration:
```json
{
    "build": {
        "arch": "armv7hf",
        "lib": ["libfapp", "curl", "openssl", "json-glib"],
        "sdk_name": "acap-native-sdk",
        "extra_package_files": ["bin"],
        "build_arg": [
            "DEBUG_SANITIZE=true"
        ]
    }
}
```

When an application is built with `fappcli-build build` the default fapp-manifest file will be used. When the application is built with `fappcli-build build --fapp-manifest fapp-manifest.debug.json` the `bin` folder will also be included in the package and the `DEBUG_SANITIZE=true` environment variable will be set when building the project. The defaults in the fapp-manifest files can always be overridden with the CLI options, e.g. when building for the AARCH64 architecture, `fappcli-build build --arch aarch64` will override the ARMv7hf specified in the fapp-manifest files.

More examples can be seen in the [Axis-ACAP-guides/fapp examples](https://github.com/fixedit-ai/Axis-ACAP-guides/blob/main/fapp).

### Common options
Most of the commands in the FApp CLI use the `.fapp` config file to get the global settings. The location of this file is described above. Any command can however take the path to another config file by using the `--config-file <PATH>` option. The configuration in this file will add to, or override, the parameters in the global file. This is useful for project specific configuration. The format of the file is the same as described above for the `.fapp` file. Try e.g. to create the config file `my_project/fapp_project_conf.json` and run the command:
```bash
fappcli-config show --config-file my_project/fapp_project_conf.json
```
To avoid repeating the same path to the project specific configuration file, the path can be added to a `fapp-manifest.json` file which will affect the build, install and run commands:
```json
{
    "build": {
        "config_file": "/tmp/myconf.json"
    }
}
```

Any command that is using the `.fapp` config file also accepts a text input to the `--config-string <VALUE>` option. This can be especially useful in CI/CD jobs where there is no permanent configuration. You can try it with e.g.:
```bash
fappcli-config show --config-string '{"cameras": {"ci_cd_cam": {"ssh-host": "192.168.0.90", "arch": "armv7hf"}}}'
```

### Coloring of output text
By default, the text output is colored to make it easier to differentiate important information such as errors and warnings from general information. If the command is redirected or piped to another command, the coloring will automatically be disabled, which allows for easier parsing of the output. To prevent coloring of the output, set the environment variable `NO_COLOR` to any value. To force coloring even when there is not tty, set `FORCE_COLOR` to any value (this can be useful for enabling color in e.g. CI/CD systems). In GitHub Actions, color is automatically forced, this means that if you want to parse the output in a GitHub Actions workflow, you should set the `NO_COLOR` variable.

### Build an application
The FApp CLI build tool can in the most simple configuration help with the process of building an ACAP in a Docker image and extracting the .eap file from the image, but the tool is much more powerful and can make advanced projects easier by making use of the fapp-manifest files for build configurations.

In the most simple case, the `fappcli-build build` command should be run with a folder directory that looks like this:
```
└── my_app_dir
    ├── app
    │   ├── LICENSE
    │   ├── Makefile
    │   └── manifest.json
    └── Dockerfile
```
The build command takes a path to the project, this defaults to the current working directory, so if you are standing in the `my_app_dir` folder, you can run `fappcli-build build`, otherwise run `fappcli-build build <PATH>/<TO>/my_app_dir`.

#### Different build styles
There are two different build modes supported, the Axis-styled builds where the `acap-build` command is run in the Dockerfile and the FixedIT-styled builds where the FApp CLI tool will run the `acap-build` command in a new container after building the image.

##### The Axis-styled builds
The first thing that always happens when the build command is run is that the `app/manifest.json` file is parsed to get e.g. application version, etc. Some of this information will be available as environment variables when the Dockerfile is built. You can see these variables and their values in the output of the build tool, e.g.:
```
DEBUG: Using environment: {'CAM_ARCH': 'armv7hf', 'ARCH': 'armv7hf', 'FAPP_BIN_NAME': 'my_app', 'FAPP_APP_NAME': 'My App', 'FAPP_APP_VERSION': '1.0.0'}
```
The Dockerfile is then built, except for the extra variables that are made available by the FApp CLI tool, this process is exactly the same as a normal Axis build. After this, the FApp CLI tool will check if an `.eap` file was created when building the image. In the case of an Axis example, where the Dockerfile might look like this, an `.eap` file was created by the `acap-build` command on the last line of the file:
```Dockerfile
ARG ARCH=armv7hf
ARG VERSION=1.9
ARG UBUNTU_VERSION=22.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}

# Building the ACAP application
COPY ./app /opt/app/
WORKDIR /opt/app
RUN . /opt/axis/acapsdk/environment-setup* && acap-build ./
```
If the `.eap` file was found in the container, this will be copied to your local build directory. Your directory could thus look like this after a build:
```
└── my_app_dir
    ├── app
    │   ├── LICENSE
    │   ├── Makefile
    │   └── manifest.json
    ├── My_App_1_0_0_armv7hf.eap
    └── Dockerfile
```

You can now try this out with the public Axis [acap-native-sdk-examples/hello_world ACAP](https://github.com/AxisCommunications/acap-native-sdk-examples/tree/09781a4370a29941176055d8412e7897f5e8ecde/hello-world). Open a terminal in the `hello_world` directory and run `fappcli-build build`. You should now have an `.eap` file in the same directory.

Another slightly more complicated example is the public Axis [acap-native-sdk-examples/vdo-larod ACAP](https://github.com/AxisCommunications/acap-native-sdk-examples/tree/09781a4370a29941176055d8412e7897f5e8ecde/vdo-larod). This example requires the Docker build arg `CHIP=<CHIP>` to build and there are multiple manifest files:
```
├── app
│   ├── imgprovider.c
│   ├── imgprovider.h
│   ├── LICENSE
│   ├── Makefile
│   ├── manifest.json.artpec8
│   ├── manifest.json.cpu
│   ├── manifest.json.cv25
│   ├── manifest.json.edgetpu
│   ├── utility-functions.c
│   ├── utility-functions.h
│   └── vdo_larod.c
├── Dockerfile
└── README.md
```
To build this application for an ARTPEC-7 camera with an Edge TPU, run the following command:
```bash
fappcli-build build --manifest-name manifest.json.edgetpu --build-arg CHIP=edgetpu --arch armv7hf
```
The command to build it for the ARTPEC-8 cameras would instead be the following:
```bash
fappcli-build build --manifest-name manifest.json.artpec8 --build-arg CHIP=artpec8 --arch aarch64
```

To avoid repeating all these options hundreads of times per day and to not have to remember which architecture goes with which DLPU chip we can now create two fapp-manifest files with build configurations.

Contents of `fapp-manifest.tpu.json`:
```json
{
  "build": {
    "manifest_name": "manifest.json.edgetpu",
    "build_arg": [
      "CHIP=edgetpu"
    ],
    "arch": "armv7hf"
  }
}
```

Contents of `fapp-manifest.a8.json`:
```json
{
  "build": {
    "manifest_name": "manifest.json.artpec8",
    "build_arg": [
      "CHIP=artpec8"
    ],
    "arch": "aarch64"
  }
}
```

The two build commands would now instead be:
```bash
fappcli-build build --fapp-manifest fapp-manifest.tpu.json
```
and:
```bash
fappcli-build build --fapp-manifest fapp-manifest.a8.json
```

##### The FixedIT-styled builds
We have now seen how the Axis-styled builds work where the `acap-build` command is called from a `RUN` command in the Dockerfile. One of the common isses we see with this is that you need to specify to the `acap-build` command which files should be included in the package. The files to be included often differ depending on which platform the ACAP is built for (as with the models included in the `vdo-larod` ACAP) or depending on other build configurations. This creates complex Dockerfiles as can even be seen in the relatively simple `vdo-larod` ACAP:
```Dockerfile
ARG ARCH=armv7hf
ARG VERSION=1.9
ARG UBUNTU_VERSION=22.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app/
ARG CHIP

# Download the pretrained model
ARG MODEL_BUCKET=https://acap-artifacts.s3.eu-north-1.amazonaws.com/models
RUN if [ "$CHIP" = artpec8 ]; then \
        curl -o model.zip $MODEL_BUCKET/models.aarch64.artpec8.zip ; \
    elif [ "$CHIP" = cpu ]; then \
        curl -o model.zip $MODEL_BUCKET/models.aarch64.artpec8.zip ; \
    elif [ "$CHIP" = edgetpu ]; then \
        curl -o model.zip $MODEL_BUCKET/models.armv7hf.edgetpu.zip ; \
    elif [ "$CHIP" = cv25 ]; then \
        curl -o model.zip $MODEL_BUCKET/tensorflow_to_larod_models.cv25.zip ; \
    else \
        printf "Error: '%s' is not a valid value for the CHIP variable\n", "$CHIP"; \
        exit 1; \
    fi && \
    unzip -q model.zip && rm -f model.zip

# Copy the library to application folder
WORKDIR /opt/app
COPY ./app .

# Build the ACAP application
RUN cp /opt/app/manifest.json.${CHIP} /opt/app/manifest.json && \
    . /opt/axis/acapsdk/environment-setup* && \
    if [ "$CHIP" = artpec8 ] || [ "$CHIP" = cpu ]; then \
        acap-build . -a 'models/converted_model.tflite'; \
    elif [ "$CHIP" = edgetpu ]; then \
        acap-build . -a 'models/converted_model_edgetpu.tflite'; \
    elif [ "$CHIP" = cv25 ]; then \
        acap-build . -a 'models/car_human_model_cavalry.bin'; \
    else \
        printf "Error: '%s' is not a valid value for the CHIP variable\n", "$CHIP"; \
        exit 1; \
fi
```

This is one of the reasons we recommend using the FixedIT-styled builds. The only difference you need to make is to not call the `acap-build` command from the Dockerfile. The FApp CLI command will then build the Docker image from the Dockerfile and find that there is no `.eap` file in the image. It will then create a container from the image and run the `acap-build` command in the `/opt/app` dir of the image. In this case you can add the `--extra-package-files` option to the build command to specify which files should be included in the package.

We will simplify the Dockerfile from the `vdo-larod` example by transforming it into a FixedIT-styled build:
```Dockerfile
ARG ARCH=armv7hf
ARG VERSION=1.9
ARG UBUNTU_VERSION=22.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app/
ARG MODEL_ZIP
ARG FAPP_MANIFEST_NAME

# Download the pretrained model
ARG MODEL_BUCKET=https://acap-artifacts.s3.eu-north-1.amazonaws.com/models
RUN curl -o model.zip $MODEL_BUCKET/$MODEL_ZIP && \
    unzip -q model.zip && rm -f model.zip

# Copy the library to application folder
WORKDIR /opt/app
COPY ./app .

# Use the correct manifest file
RUN mv $FAPP_MANIFEST_NAME manifest.json
```

A few modifications are now needed in the fapp-manifest files.

Contents of `fapp-manifest.tpu.json`:
```json
{
  "build": {
    "manifest_name": "manifest.json.edgetpu",
    "build_arg": [
      "MODEL_ZIP=models.armv7hf.edgetpu.zip"
    ],
    "arch": "armv7hf",
    "extra_package_files": [
      "models/converted_model_edgetpu.tflite"
    ]
  }
}
```

Contents of `fapp-manifest.a8.json`:
```json
{
  "build": {
    "manifest_name": "manifest.json.artpec8",
    "build_arg": [
      "MODEL_ZIP=models.aarch64.artpec8.zip"
    ],
    "arch": "aarch64",
    "extra_package_files": [
      "models/converted_model.tflite"
    ]
  }
}
```

The most important modification we did was to remove the `acap-build` command from the Dockerfile and instead specify the model files with the `--extra-package-files` option (or in this case in the fapp-manifest file with the `build.extra_package_files` key). We also removed the `CHIP` variable and instead specified the `MODEL_ZIP` path as a build arg. Lastly, instead of using the `CHIP` variable to find the correct manifest file, we made use of the `FAPP_MANIFEST_NAME` variable that is automatically set whenever the `--manifest-name` option (or the `build.manifest_name` key) is specified.

#### Selecting the SDK and base image
The next step in making the project scalable is to make it easy to build the application with different SDKs. This is often needed in more complex projects since you will find that the new SDKs have new features that you want to make use of when possible, but the new SDKs are not supported in all cameras. Therefore you will likely end up building the same application with multiple SDKs and build configurations.

Since the SDK name and version are set using build args, you could handle this by specifying them as `build.build_arg` in the fapp-manifest files. You would however discover that there are some differences between the SDKs (especially SDK 3 and SDK 4) that can be complex to handle. Therefore you can make use of the FixedIT base images which expand the Axis SDK with some usability tools and backporting of some tools to older SDKs.

You can find an example of this in the [Axis-ACAP-guides/fapp/curl_example ACAP](https://github.com/fixedit-ai/Axis-ACAP-guides/tree/main/fapp/curl_example). The two things we need to change are these lines in the Dockerfile:
```Dockerfile
ARG ARCH=armv7hf
ARG VERSION=1.9
ARG UBUNTU_VERSION=22.04
ARG REPO=axisecp
ARG SDK=acap-native-sdk

FROM ${REPO}/${SDK}:${VERSION}-${ARCH}-ubuntu${UBUNTU_VERSION}
```
to:
```Dockerfile
ARG FAPP_IMAGE_BUILDER_BASE
FROM ${FAPP_IMAGE_BUILDER_BASE} as builder
```

We can then update the fapp-manifest files with the `build.sdk_name` key or specify `--sdk-name acap-native-sdk` on the command line. Doing so will build the application with the latest available version of Native SDK 4 that we are offering the builder-base image for. If you instead want to build the ACAP with SDK 3, you can do so by specifying `--sdk-name acap-sdk` (to make the ACAP compatible with SDK 3, you also need to change the `schemaVersion` in the manifest file to `1.3`). Using the latest available SDK version can be good when prototyping, but for production usage you should specify a specific version with e.g. `--sdk-version 1.6`.

#### Making use of prebuilt libraries
Cross-compiling libraries such as openssl, curl, json serializer libraries or more advanced libraries such as QR-code detection or OCR-decoding can be complex. Therefore FixedIT offers prebuilt libraries for the Axis cameras.

To make use of prebuilt libraries, you need to use our SDK base images as described above. Examples on how to use our prebuilt libraries can be found in [Axis-ACAP-guides/fapp/curl_example ACAP](https://github.com/fixedit-ai/Axis-ACAP-guides/tree/main/fapp/curl_example) and [Axis-ACAP-guides/fapp/sentry_example ACAP](https://github.com/fixedit-ai/Axis-ACAP-guides/tree/main/fapp/sentry_example).

For production code, we strongly recommend locking the library version with `--docker-lib-version <LIBRARY_VERSION>`. To use a library that was recently added to the library repository or to use a recently released version of the SDK you might need to update the library version to the latest release. See the [List FixedIT precompiled library versions section](#list-fixedit-precompiled-library-versions) for instruction on how to list available library versions.

#### Debugging failed builds
When a build fails due to e.g. compilation errors, it can be useful to know what the file system currently looks like inside the builder container. This could be used to e.g. verify the location of an include file produced in one compilation step that is not found in another compilation step.

When using the FixedIT-styled builds, if a build fails the build root (i.e. the `/opt/app` dir in the container) will automatically be dumped to the host computer as a folder called `build_root` for easy inspection. All output from the build command will also be written to the `build.log` file created in the build directory. If you want to dump the build directory even when the compilation doesn't fail, you can do so by specifying the flag `--dump-build-dir`. If you wish to access the full container that the build was performed in, you can instead specify `--dump-build-container` which will commit the container as a new image. The name of the image created can be found in the output of the command.

#### Adding extra files
We could see in the [The FixedIT-styled builds section](#the-fixedit-styled-builds) how we can add extra files that should be included in the `.eap` package using the FApp CLI options. You should however note that the file must exist before the `acap-build` command is run, therefore the file can't be created by e.g. the Makefile. Instead you can often create the file in the Dockefile. Also note that this option does not work for the Axis styled builds as the `acap-build` command is manually called from the Dockerfile and there is then no way for the FApp CLI to specify the file list to the command.

### List FixedIT precompiled library versions
It is currently not possible to list all available FixedIT prebuilt libraries with the tool, instead you should contact fixedit.ai to get the current list of libraries we offer.

Each library exists in multiple versions:
- Every time we make a new release of the libraries we give them a library version date on the form `YYYY-MM-DD_HH-MM-SS`. This is what you can specify to the build command with the `--docker-lib-version` option. This can also be set to 'latest'. A release like this can contain e.g. bug-fixes in the way we build the library, an update on the version tag of the upstream library that we use, or other changes that might not affect this library. You should always use the same library version date for all libraries, this means that if we maintain libraries A, B and C, and we make a change to library B, then we will rebuild all libraries (A, B, and C) so that they get new version dates.
- For each version date that the libraries are built for, we build them for all combinations of the SDKs, SDK versions (minors), and camera architectures that we support. The amount of supported combinations can differ between different library version dates or libraries. E.g. the common library A with version date `1234-01-01_00-00-00` might be built for ACAP SDK 3.3 and 3.5 and Native SDK 4.1, 4.7 and 4.10 for both aarch64 and armv7hf, while library B which is a very specific library, with the same version date, might only be built for Native SDK 4.7 and 4.10 for architecture aarch64. In the next version date, Native SDK 4.11 might be added to both library A and B.
- All the released library versions are found in the Production repo, specified to the build command with `--docker-lib-env [dev|prod]` while the Development repo contains work-in-progress versions of the libraries. You should never use the Development repo unless you are specifically instructed to do so in order to temporary try some work-in-progress fix.

To list all available versions of the libraries you can use the `fappcli-build list-libraries` command. If you run it without options you will see which SDK-versions that are currently supported by the `builder-base` library. As explained above, a specific library might be built with fewer supported SDK versions than another, therefore you can list e.g. the supported SDK versions for the `curl` library with `fappcli-build list-libraries --library-name curl`.

To list the version dates that exists for a specific library, type `fappcli-build list-libraries --show-version`, or to list both version dates and which SDK versions they support, type `fappcli-build list-libraries --show-version --show-sdk`. Note that there are a lot of information being parsed for this command and it may take some time to list it all. If you are interested in a particular SDK (major) you can use the `--sdk-name` option to filter for e.g. only `acap-native-sdk`. To filter on a specific version date and print the supported SDKs and SDK versions, use `fappcli-build list-libraries --show-sdk --docker-lib-version <VERSION>` where `<VERSION>` is replaced by the version on the `YYYY-MM-DD_HH-MM-SS` format.

### Validate an .eap file
When you have built an `.eap` file for your application, there are some static checks that can be done to test the validity of the file. For this, the `fappcli-test` command can be used. The idea with the tool is not to test if the application does what it should do, but to test if it will be able to run in the camera. It will test things such as:
- Test that the application archive format is valid.
- Test that the binary files are built for the architecture specified in the manifest file and in the `.eap` file name.
- Test that the file name is on the format `<APP_NAME>_<VERSION>_<ARCH>.eap` with the version on the format `<MAJOR>_<MINOR>_<PATCH>` (can be disabled with `--ignore-file-name`)
- Test that the application main binary exists and has the correct naming.

These tests can allow you to identify issues early or to implement CI/CD verification jobs. The architecture tests are especially useful when cross-compiling libraries to avoid accidentally including libraries or binaries built for host instead of the target.

Run the command like:
```bash
fappcli-test myapp.eap
```

The return code of the command will be 0 on success, otherwise non-zero.

To list the different test cases, add `-v` to the command. To also list all the files in the `.eap` package, instead add `-vv`.

In some cases you might want to disable specific tests, e.g.:
- When building an ACAP with an older SDK that does not include the `acap-build` command, the `manifest.json` file will not be included. In this case you can disable the check for the manifest file with `--no-manifest-ok`. This will also cause the tool to skip some tests that depend on the manifest file.
- If you have done custom renaming of the `.eap` file, you can disable the file name check with `--ignore-file-name`.
- If you are bundling hundreds of libraries or more, the command might get rather slow. To make it faster, you can skip the architecture check of the other files by specifying `--ignore-other-elf-files`. The tool will then only check the architecture of the primary binary.
- Normally the architecture will be derived from the manifest file in the `.eap` file, if you want to override this you can do so with `--arch`.
- Normally the tool only returns non-zero exit on errors, to also do this on warnings you can specify `--strict`. This is useful in CI/CD jobs.

### List connected devices
The `fappcli-deploy list` command can be used to list the devices configured in the FApp configuration. This command will test access to each camera and generate a table with the status overview. The command will also print helpful warning such as detecting if SSH is not enabled in a camera or if the credentials are not valid. This is useful for debugging the configuration and camera setup. To allow connection to cameras with invalid SSL certificates, add the `--insecure` flag which will disable certificate validation.

Example output:
```
WARNING: Could not authenticate ssh to camera cam-1075, check credentials
WARNING: Could not connect to camera speaker-1, ssh not enabled?
+---------------+--------+---------------+---------------+--------------+
|     Camera    | Status |   HTTPS host  |    SSH host   | Architecture |
+---------------+--------+---------------+---------------+--------------+
|    cam-tpu    |   OK   |               |    cam-tpu    |   armv7hf    |
|     cam-a8    |   OK   | 192.168.0.195 |               |   aarch64    |
|    cam-1065   |   OK   |               |    cam-1065   |   armv7hf    |
|    cam-1075   | FAILED |               |    cam-1075   |   aarch64    |
|    cam-cv25   |   OK   |               |    cam-cv25   |   aarch64    |
|   speaker-1   | FAILED |               |   speaker-1   |   armv7hf    |
|     strobe    |   OK   |               |     strobe    |   armv7hf    |
+---------------+--------+---------------+---------------+--------------+
```

### Install an application in the camera
To allow for rapid prototyping the `fappcli-deploy install` command can be used instead of installing applications from the Axis web UI. If you specify a path to an `.eap` file, that application will be installed in the camera. If the path (or the current working directory if no path is specified) is instead a build directory, the `fappcli-build build` command will automatically be invoked to build the `.eap` file for the correct architecture. This command thus accepts all options that the build command accepts.

If no camera is specified, an arbitrary camera from your configuration, that is compatible with the applications architecture will be used. Otherwise specify the camera with `--camera`. If the camera does not have a valid SSL certificate, specify `--insecure` to ignore certificate validation.

### Run an application
For rapid testing of changes to the application code the FApp CLI tool also provides a way to build, install and run the application with a single command.  `fappcli-deploy run` will do the same as described in [Install an application in the camera](#install-an-application-in-the-camera) and then SSH to the camera and run the main application binary from the command line. All the output from the applications stdout and stderr will be redirected to the users terminal. Note that messages written to the system log is not forwarded to stdout in the older firmware versions, for this, see the [Axis-ACAP-guides/fapp examples](https://github.com/fixedit-ai/Axis-ACAP-guides/blob/main/fapp) on the usage of `fapp_logger_init(APP_NAME)` and `fapp_logger_log(<LOG_LEVEL>, <MESSAGE>)`.

This command will also parse the `manifest.json` file in the application, if there are any `acapPackageConf.setup.runOptions` specified, they will be used when running the application. This command might not work for all applications, as some applications expects specific environment variables to be set by the ACAP runtime.

To allow connection to cameras without valid SSL certificate, specify `--insecure`.

## Troubleshoting

### denied: Your authorization token has expired. Reauthenticate and try again.
You might have expired login sections in your docker config, on Linux, try to remove it (but create a backup copy of the file first):
```
mv ~/.docker/config.json ~/.old.docker.config.json
```

### There is no build.log file created when building
This is only created for [The FixedIT-styled builds](#the-fixedit-styled-builds). Verify that you do not build the `.eap` file (with `acap-build`) in the Dockerfile or in any other way have an `.eap` in the Docker image.

### Getting InvalidSignatureException when listing libraries
This is an issue with the ECR signature. The most likely reason is that your computers time is not correctly set which might lead to certificate validation problems.

### Changelog

### 0.2.0
- Initial release for Windows
- Default to HTTPS instead of HTTP
- Add --insecure option
- Fix parsing of new Docker desktop output
- Add option to dump container and fix Windows validation of dump build dir
- Add library list command
- Add show version command
- Move README to the python package
- Create installation scripts for fappcli
- Misc bug fixes

### 0.1.0
- Mix fixes for output coloring and new color library
- Bug fixes

### 0.0.2
Alpha version with support for Linux and MacOS.