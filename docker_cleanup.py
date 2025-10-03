import subprocess
import os
import shutil

def run_command(command):
    """Run shell command and suppress errors"""
    try:
        subprocess.run(command, shell=True, check=True)
    except subprocess.CalledProcessError:
        pass  # ignore errors for non-existing resources

def remove_all_docker_containers():
    print("🧼 Stopping and removing all Docker containers...")
    run_command("docker ps -aq | xargs -r docker rm -f")

def remove_all_docker_images():
    print("🗑️ Removing all Docker images...")
    run_command("docker images -aq | xargs -r docker rmi -f")

def remove_all_docker_volumes():
    print("🧹 Removing all Docker volumes...")
    run_command("docker volume ls -q | xargs -r docker volume rm")

def clean_jenkins_workspace():
    print("📁 Cleaning Jenkins workspace builds...")
    # Check common Jenkins home paths
    jenkins_paths = [
        "/var/lib/jenkins/workspace",         # Linux default
        os.path.expanduser("~/jenkins/workspace"),  # User dir
        os.path.expanduser("~/workspace"),    # Generic fallback
    ]
    
    for path in jenkins_paths:
        if os.path.exists(path):
            print(f"🗑️ Found workspace at {path}, deleting build dirs...")
            for item in os.listdir(path):
                item_path = os.path.join(path, item)
                try:
                    if os.path.isdir(item_path):
                        shutil.rmtree(item_path)
                        print(f"  ➤ Deleted: {item_path}")
                except Exception as e:
                    print(f"  ⚠️ Failed to delete {item_path}: {e}")

if __name__ == "__main__":
    remove_all_docker_containers()
    remove_all_docker_images()
    remove_all_docker_volumes()
    clean_jenkins_workspace()

    print("\n✅ Docker and Jenkins workspace cleanup complete.")
