# -----------------------------
# DevOps All-in-One Jenkins Image
# Includes: Jenkins + Docker CLI + AWS CLI + Terraform
# -----------------------------
FROM jenkins/jenkins:lts

USER root

# Install essential dependencies (Debian 13+ safe)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates curl unzip git python3 python3-pip sudo gnupg lsb-release && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install AWS CLI v2
# -----------------------------
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip" && \
    unzip /tmp/awscliv2.zip -d /tmp && \
    /tmp/aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# -----------------------------
# Install Terraform
# -----------------------------
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Docker CLI (for Jenkins builds)
# -----------------------------
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Create Docker group manually and add Jenkins user to it
# -----------------------------
RUN groupadd -f docker && usermod -aG docker jenkins

# -----------------------------
# Ports for Jenkins Web and Agent
# -----------------------------
EXPOSE 8080 50000

USER jenkins
