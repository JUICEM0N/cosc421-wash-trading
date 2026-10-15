from washtrading.download import download_all


def main():
    for path in download_all():
        print(path)


if __name__ == "__main__":
    main()
